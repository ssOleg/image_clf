#!/usr/bin/env bash

name = image_clf

create_tensor_session:
    tmux new-session -s $(name) -d
    tmux split-window -v -t $(name):0.0

run_tensor_server:
    tmux send -t $(name):0.0 "tensorflow_model_server --model_base_path=/models --rest_api_port=9000 --model_name=ImageCLF" C-m

run_flask_server:
    tmux split-window -v -t $(name):0.1
    tmux send -t $(name):0.2 "cd /app && python3 app.py" C-m

run_react:
    tmux send -t $(name):0.1 "cd /app && npm run build && npm start" C-m

start_services: create_tensor_session run_tensor_server run_react run_flask_server

stop_services:
    tmux kill-session -t $(name)

attach_session:
    tmux -2 attach-session -d

restart_services: kill_session start_services