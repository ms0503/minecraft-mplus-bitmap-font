use serde::Deserialize;
use serde::Serialize;
use std::collections::HashMap;
use std::env;
use std::io::prelude::*;
use tokio::fs::File;
use tokio::io::AsyncBufReadExt;
use tokio::io::AsyncWriteExt;
use tokio::io::BufReader;
use tokio::io::Lines;
use tokio::join;

const EMPTY: String = String::new();

pub async fn run() {
    let args: Vec<_> = env::args().collect();
    if args.len() != 5 {
        eprintln!(
            "Usage: {} <convertion_table> <bdf_file> <base_json_file> <output_json_file>",
            args[0]
        );
        std::process::exit(1);
    }
    let (table, mut lines, mut font) = join!(
        load_table(&args[1]),
        initialize_bdf_reader(&args[2]),
        open_json(&args[3])
    );
    font.providers[0].chars = vec![];
    let mut buf = [EMPTY; 16];
    let mut i = 0;
    while let Some(code) = get_next_char_code(&mut lines).await {
        let code = table
            .get(&code)
            .unwrap_or_else(|| panic!("failed to convert unknown jis code: 0x{:04x}", code));
        buf[i] = format!("\\u{:04x}", code);
        i += 1;
        if i == 16 {
            i = 0;
            font.providers[0].chars.push(buf.join(""));
        }
    }
    if i != 0 {
        font.providers[0].chars.push(buf.join(""));
    }
    let json = serde_json::to_string(&font)
        .expect("failed to serialize to json")
        .replace("\\\\", "\\");
    let mut buf = vec![];
    write!(buf, "{}", json).unwrap();
    let mut out = File::create(&args[4])
        .await
        .expect("failed to create output file");
    out.write_all(&buf)
        .await
        .expect("failed to write output file");
}

#[derive(Debug, Deserialize, PartialEq, Serialize)]
struct Provider {
    pub ascent: i32,
    pub chars: Vec<String>,
    pub file: String,
    #[serde(rename = "type")]
    pub font_type: String,
    pub height: i32
}

#[derive(Debug, Deserialize, PartialEq, Serialize)]
struct Font {
    pub providers: Vec<Provider>
}

async fn load_table(filename: &str) -> HashMap<u16, u16> {
    let mut table = HashMap::new();
    let file = File::open(filename)
        .await
        .expect("failed to open convertion table file");
    let mut rows = BufReader::new(file).lines();
    while let Some(row) = rows
        .next_line()
        .await
        .expect("failed to read line of convertion table")
    {
        let cols: Vec<_> = row.split("\t").collect();
        let jis = u16::from_str_radix(&cols[0][2..], 16).expect("invalid table data");
        let uni = u16::from_str_radix(&cols[1][2..], 16).expect("invalid table data");
        table.insert(jis, uni);
    }
    table
}

async fn initialize_bdf_reader(filename: &str) -> Lines<BufReader<File>> {
    let file = File::open(filename).await.expect("failed to open bdf file");
    let mut lines = BufReader::new(file).lines();
    skip_header(&mut lines).await;
    lines
}

async fn open_json(filename: &str) -> Font {
    let file = std::fs::File::open(filename).expect("failed to open json file");
    let mut reader = std::io::BufReader::new(file);
    serde_json::from_reader(&mut reader).expect("failed to parse json")
}

async fn skip_header(lines: &mut Lines<BufReader<File>>) {
    while let Some(line) = lines.next_line().await.expect("failed to read line of bdf") {
        if line.starts_with("CHARS ") {
            return;
        }
    }
    panic!("invalid bdf");
}

async fn get_next_char_code(lines: &mut Lines<BufReader<File>>) -> Option<u16> {
    while let Some(line) = lines.next_line().await.expect("failed to read line of bdf") {
        if line.starts_with("ENCODING ") {
            return Some(
                line.split_whitespace().collect::<Vec<_>>()[1]
                    .parse::<u16>()
                    .expect("failed to parse char code")
            );
        }
    }
    None
}
