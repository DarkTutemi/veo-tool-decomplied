@echo off
echo ============================================================
echo   STARTING VEOFLOW PRO MAX - DEMO MODE (NO PATCH)
echo   All requests will be logged to capture_demo_log.txt
echo   Close the app window when done to stop logging.
echo ============================================================
cd /d H:\veo-tool
uv run --python 3.12 python loader_demo.py --no-mock
pause
