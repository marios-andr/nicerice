use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use glob::glob;
use std::fs;
use std::path::Path;

#[derive(Debug, Deserialize, Serialize)]
pub struct Config {
    pub calendars: HashMap<String, CalendarEntry>,
    #[serde(rename = "default")]
    pub default_section: DefaultSection,
    pub locale: Option<Locale>,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct Locale {
    pub dateformat: String,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct DefaultSection {
    pub default_calendar: String,
}


#[derive(Debug, Deserialize, Serialize)]
pub struct CalendarEntry {
    pub path: String,
    #[serde(rename = "type")]
    pub typez: Option<String>,
    pub color: Option<String>,
}

#[derive(Debug, Serialize)]
pub struct Calendar {
    pub name: String,
    pub khal_name: String,
    pub display_name: String,
    pub color: Option<String>,
    pub path: String,
    #[serde(rename = "type")]
    pub typez: String,
}

impl Calendar {
    pub fn from_entry(calendar_key: &String, item: &CalendarEntry) -> Vec<Calendar> {
        let path = &item.path;
        let color = &item.color;
        let typez = &item.typez.clone().unwrap_or_else(|| "calendar".to_string());

        if typez  == "discover" {
            let mut calendars = Vec::new();

            let entries = match glob(&path) {
                Ok(paths) => paths,
                Err(e) => {
                    eprintln!("invalid glob pattern '{path}': {e}");
                    return calendars;
                }
            };

            for entry in entries {
                let dir_path = match entry {
                    Ok(p) => p,
                    Err(e) => {
                        eprintln!("error reading glob entry: {e}");
                        continue;
                    }
                };

                if !dir_path.is_dir() {
                    continue;
                }

                let folder_name = dir_path
                    .file_name()
                    .map(|n| n.to_string_lossy().to_string())
                    .unwrap_or_else(|| calendar_key.clone());

                let display_name = fs::read_to_string(&dir_path.join("displayname"))
                    .ok()
                    .filter(|s| !s.is_empty()) 
                    .map(|s| s.trim().to_string());

                let color = fs::read_to_string(&dir_path.join("color"))
                    .ok()
                    .filter(|s| !s.is_empty()) 
                    .map(|s| s.trim().to_string())
                    .map(|s| s[..7].to_string())
                    .or_else(|| color.clone());

                calendars.push(Calendar {
                    name: calendar_key.clone(), 
                    khal_name: folder_name.clone(),
                    display_name: display_name.unwrap_or_else(|| folder_name), 
                    color, 
                    path: dir_path.to_string_lossy().to_string(), 
                    typez: typez.clone() 
                });
            }


            calendars
        } else {
            let file_path = Path::new(path);
            let display_name = fs::read_to_string(&file_path.join("displayname"))
                    .ok()
                    .filter(|s| !s.is_empty()) 
                    .map(|s| s.trim().to_string());
            let color = fs::read_to_string(&file_path.join("color"))
                    .ok()
                    .filter(|s| !s.is_empty()) 
                    .map(|s| s.trim().to_string())
                    .map(|s| s[..7].to_string())
                    .or_else(|| color.clone());

            vec![Calendar {
                name: calendar_key.clone(),
                khal_name: calendar_key.clone(),
                display_name: display_name.unwrap_or_else(|| calendar_key.clone()),
                color: color.clone(),
                path: path.clone(),
                typez: typez.clone(),
            }]
        }
    }
}

