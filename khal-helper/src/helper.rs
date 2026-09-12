use chrono::{NaiveDate, Duration};
use anyhow::{Result, Context};

pub fn date_range(start_date: &str, end_date: &str) -> Result<Vec<String>> {
    let start = NaiveDate::parse_from_str(start_date, "%Y-%m-%d")
        .with_context(|| format!("invalid start date: {start_date}"))?;
    let end = NaiveDate::parse_from_str(end_date, "%Y-%m-%d")
        .with_context(|| format!("invalid end date: {end_date}"))?;

    let mut dates = Vec::new();
    let mut current = start;

    while current <= end {
        dates.push(current.format("%Y-%m-%d").to_string());
        current += Duration::days(1);
    }

    Ok(dates)
}