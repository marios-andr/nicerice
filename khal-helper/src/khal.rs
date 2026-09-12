use crate::{
    calendars::{Calendar, Config},
    events::{DayEvents, Event},
    helper::date_range,
};
use chrono::NaiveDate;
use anyhow::{Context, Result, bail};
use std::collections::HashMap;
use std::env::var;
use std::process::Command;

const KHAL_CONF_PATH: &'static str = "/.config/khal/config";
const SCRIPTS_PATH: &'static str = "/.config/nicerice/scripts/";

fn format_date(date: &str, format: &str) -> Result<String> {
    // root.isoDateTime()
    let output = Command::new("date")
        .arg("-d")
        .arg(date)
        .arg(format!("+{format}"))
        .output()?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        bail!("failed to parse date {date}: {stderr}");
    }

    let stdout = String::from_utf8_lossy(&output.stdout);
    Ok(stdout.trim().to_string())
}

/// Khal returns multiple arrays as concatenated instead of proper json arrays
fn parse_khal_json(text: &str, start_date: &str, end_date: &str) -> Result<Vec<DayEvents>> {
    if text.trim().is_empty() {
        return Ok(vec![]);
    }

    if start_date == end_date {
        let events: Vec<Event> = serde_json::from_str(text)?;
        let mut day_events: Vec<DayEvents> = Vec::new();
        let saved_date = NaiveDate::parse_from_str(start_date, "%Y-%m-%d")
        .with_context(|| format!("invalid start date: {start_date}"))?;
        day_events.push(DayEvents {
            date: saved_date.format("%Y-%m-%d").to_string(),
            events,
        });
        Ok(day_events)
    } else {
        let mut day_events: Vec<DayEvents> = Vec::new();
        let date_range = date_range(start_date, end_date)?;

        for (line, date) in text
            .lines()
            .filter(|l| !l.trim().is_empty())
            .zip(date_range.iter())
        {
            let parsed: Vec<Event> = serde_json::from_str(line)
                .with_context(|| format!("failed to parse khal line: {line}"))?;
            day_events.push(DayEvents {
                date: date.clone(),
                events: parsed,
            });
        }

        Ok(day_events)
    }
}

pub fn parse_config() -> Result<Config> {
    let out: std::process::Output = Command::new("python3")
        .arg(var("HOME").unwrap() + SCRIPTS_PATH + "read-khalconf.py")
        .arg(var("HOME").unwrap() + KHAL_CONF_PATH)
        .output()?;

    if !out.status.success() {
        let stderr = String::from_utf8_lossy(&out.stderr);
        bail!("failed to parse khal config file at {KHAL_CONF_PATH}: {stderr}");
    }

    let stdout = String::from_utf8_lossy(&out.stdout);
    // println!("{}", &stdout);
    let value = serde_json::from_str::<Config>(&stdout)?;
    Ok(value)
}

pub fn list_events(conf: &Config, date: &str, end_date: &str) -> Result<Vec<DayEvents>> {
    let localdate_format = match &conf.locale {
        None => "%x",
        Some(locale) => locale.dateformat.as_str(),
    };
    let formatted_date = format_date(date, localdate_format)?;
    let end_formatted_date = format_date(end_date, localdate_format)?;

    let output = Command::new("khal")
        .arg("list")
        .arg(&formatted_date)
        .arg(&end_formatted_date)
        .args(["--json", "title"])
        .args(["--json", "description"])
        .args(["--json", "start-date-long"])
        .args(["--json", "end-date-long"])
        .args(["--json", "start-time"])
        .args(["--json", "end-time"])
        .args(["--json", "duration"])
        .args(["--json", "uid"])
        .args(["--json", "repeat-symbol"])
        .args(["--json", "alarms-list"])
        .args(["--json", "location"])
        .args(["--json", "calendar"])
        .args(["--json", "calendar-color"])
        .args(["--json", "url"])
        .args(["--json", "all-day"])
        .output()?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        bail!("khal exited with error: {stderr}");
    }
    
    let stdout = String::from_utf8_lossy(&output.stdout);
    let mut events = parse_khal_json(&stdout, date, end_date)?;
    let calendars = get_calendars(&conf);

    let name_lookup: HashMap<&str, &str> = calendars
        .iter()
        .map(|c| (c.name.as_str(), c.display_name.as_str()))
        .collect();

    for event in events.iter_mut().flat_map(|e| e.events.iter_mut()) {
        if let Some(display_name) = name_lookup.get(event.calendar.as_str()) {
            event.calendar = display_name.to_string();
        }
    }

    Ok(events)
}

pub fn event_overview(conf: &Config, start_date: &str, end_date: &str) -> Result<Vec<bool>> {
    let localdate_format = match &conf.locale {
        None => "%x",
        Some(locale) => locale.dateformat.as_str(),
    };
    let start_formatted_date = format_date(start_date, localdate_format)?;
    let end_formatted_date = format_date(end_date, localdate_format)?;

    let output = Command::new("khal")
        .arg("list")
        .arg(&start_formatted_date)
        .arg(&end_formatted_date)
        .args(["--json", ""])
        .output()?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        bail!("khal exited with error: {stderr}");
    }

    let stdout = String::from_utf8_lossy(&output.stdout);

    let days: Result<Vec<bool>> = stdout
        .lines()
        .filter(|line| !line.trim().is_empty())
        .map(|line| {
            let parsed: serde_json::Value = serde_json::from_str(line)
                .with_context(|| format!("failed to parse khal line: {line}"))?;

            let has_events = parsed
                .as_array()
                .map(|arr| !arr.is_empty())
                .unwrap_or(false);

            Ok(has_events)
        })
        .collect();

    days
}

pub fn edit_event(conf: &Config) {}

pub fn get_calendars(config: &Config) -> Vec<Calendar> {
    let mut calendars: Vec<Calendar> = Vec::new();
    for (key, value) in &config.calendars {
        calendars.extend(Calendar::from_entry(key, value));
    }
    calendars
}

pub fn add_calendar(conf: &Config) {}

pub fn edit_calendar(conf: &Config) {}
