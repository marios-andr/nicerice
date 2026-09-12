use serde::{Deserialize, Serialize};

#[derive(Serialize)]
pub struct DayEvents {
    pub date: String,
    pub events: Vec<Event>,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct Event {
    pub title: String,
    pub description: String,

    #[serde(rename = "start-date-long")]
    pub start_date_long: String,
    #[serde(rename = "end-date-long")]
    pub end_date_long: String,
    #[serde(rename = "start-time")]
    pub start_time: String,
    #[serde(rename = "end-time")]
    pub end_time: String,

    pub duration: String,
    pub uid: String,

    #[serde(rename = "repeat-symbol")]
    pub repeat_symbol: String,
    #[serde(rename = "alarms-list")]
    pub alarms_list: Option<Vec<Alarm>>,

    pub location: String,
    pub calendar: String,

    #[serde(rename = "calendar-color", deserialize_with = "strip_alpha")]
    pub calendar_color: String,

    pub url: String,

    #[serde(rename = "all-day", deserialize_with = "bool_from_string")]
    pub all_day: bool,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct Alarm {
    pub delta: f64,
    pub description: String,
    #[serde(rename = "delta-formatted")]
    pub delta_formatted: String,
}

fn strip_alpha<'de, D>(deserializer: D) -> Result<String, D::Error>
where
    D: serde::Deserializer<'de>,
{
    let s: Option<String> = Option::deserialize(deserializer)?;
    Ok(match s {
        Some(hex) if hex.starts_with("#") => hex[..7].to_string(),
        Some(hex) => hex.to_string(),
        None => "#888888".to_string(),
    })
}

fn bool_from_string<'de, D>(deserializer: D) -> Result<bool, D::Error>
where
    D: serde::Deserializer<'de>,
{
    let s: String = String::deserialize(deserializer)?;
    Ok(s.eq_ignore_ascii_case("true"))
}
