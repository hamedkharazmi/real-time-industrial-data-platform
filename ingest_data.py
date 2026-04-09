import pandas as pd
import click
import os
import subprocess
import gcsfs

@click.command()
@click.option('--input-path', default='data/sensor.csv', help='Local path to dataset')
@click.option('--output-path', default=None, help='Local fallback path (optional)')
@click.option('--date', required=True, help='Date to ingest (YYYY-MM-DD)')
@click.option('--download', is_flag=True, help='Force download from Kaggle')
def run(input_path, output_path, date, download):

    dataset_path = "data/"
    bucket_name = os.getenv("GCS_BUCKET")

    # Check file
    if not os.path.exists(input_path):
        print(f"File NOT found at {input_path}")
    else:
        print(f"File FOUND at {input_path}")

    # Download if needed
    if download or not os.path.exists(input_path):
        print("Downloading dataset from Kaggle...")
        subprocess.run([
            "kaggle", "datasets", "download",
            "-d", "nphantawee/pump-sensor-data",
            "-p", dataset_path,
            "--unzip"
        ], check=True)
        input_path = os.path.join(dataset_path, "sensor.csv")

    print(f'Using dataset: {input_path}')

    # Load dataset
    df = pd.read_csv(input_path)
    df['timestamp'] = pd.to_datetime(df['timestamp'])
    df = df.sort_values('timestamp')

    # Filter by date
    df['date'] = df['timestamp'].dt.date
    df_day = df[df['date'] == pd.to_datetime(date).date()]

    if df_day.empty:
        print(f'No data for {date}')
        return

    df_day = df_day.drop(columns=['date'])

    # =========================
    # WRITE TO GCS (PRIMARY)
    # =========================
    if bucket_name:
        gcs_path = f"sensor_data/date={date}/data.parquet"
        full_path = f"gs://{bucket_name}/{gcs_path}"

        print(f"Uploading to GCS: {full_path}")

        fs = gcsfs.GCSFileSystem()  # Auth comes from GOOGLE_APPLICATION_CREDENTIALS
        with fs.open(full_path, "wb") as f:
            df_day.to_parquet(f, engine="pyarrow", index=False)

        print(f'Saved {len(df_day)} rows to {full_path}')

    # =========================
    # LOCAL FALLBACK (OPTIONAL)
    # =========================
    elif output_path:
        output_dir = os.path.join(output_path, f'date={date}')
        os.makedirs(output_dir, exist_ok=True)
        output_file = os.path.join(output_dir, "data.parquet")
        df_day.to_parquet(output_file, index=False)
        print(f'Saved {len(df_day)} rows to {output_file}')

    else:
        raise ValueError("Either GCS_BUCKET env or --output-path must be provided")

if __name__ == '__main__':
    run()