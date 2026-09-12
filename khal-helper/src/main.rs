use clap::{Parser, Subcommand};
use anyhow::Result;

mod helper;
mod khal;
mod calendars;
mod events;

#[derive(Parser)]
#[command(name = "khal-helper")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// List events for a given date, date must be in the form yyyy-MM-dd HH:mm:ss
    List {
        #[arg(short, long)]
        start_date: String,
        #[arg(short, long)]
        end_date: Option<String>
    },
    /// Brief overview of which dates within the range contain at least one event.
    Overview {
        #[arg(short, long)]
        start_date: String,
        #[arg(short, long)]
        end_date: String,
    },
    /// List all calendars registered in khal.
    Calendars {
    }
}


fn main() -> Result<()> {
    let cli = Cli::parse();
    match cli.command {
        Commands::List { start_date, end_date } => {
            let config = khal::parse_config()?;

            let list: Vec<events::DayEvents>;
            match end_date {
                None => list = khal::list_events(&config, &start_date, &start_date)?,
                Some(d) => list = khal::list_events(&config, &start_date, &d)?,
            };
            println!("{}", serde_json::to_string(&list)?);
            Ok(())
        }

        Commands::Overview { start_date, end_date } => {
            let conf = khal::parse_config()?;
            let vec = khal::event_overview(&conf, &start_date, &end_date)?;
            
            print!("[");
            for day in vec {
                print!("{},", day);
            }
            println!("]");
            Ok(())
        }

        Commands::Calendars {  } => {
            let config = khal::parse_config()?;
            let calendars = khal::get_calendars(&config);
            println!("{}", serde_json::to_string(&calendars)?);
            Ok(())
        }
    }
}
