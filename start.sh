#!/bin/bash
set -e

name=image_clf
tmux new-session -s $name -d
tmux split-window -v -t $name:0.0
tmux send -t $name:0.0 "tensorflow_model_server --model_base_path=/models --rest_api_port=9000 --model_name=ImageCLF" C-m
tmux split-window -v -t $name:0.1
tmux send -t $name:0.2 "cd /app && npm run build && npm start" C-m
