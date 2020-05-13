import base64
import json
import requests

from flask import Flask, flash, request, redirect, jsonify, render_template
from werkzeug.utils import secure_filename

app = Flask(__name__)
debug = True
host = '0.0.0.0'
port = 5000

ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}


def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


@app.route('/')
def main_page():
    return render_template('index.html')


@app.route('/api/predictions', methods=['GET', 'POST'])
def upload_file():
    result_map = ['roses', 'sunflowers', 'daisy', 'dandelion', 'tulips']
    if request.method == 'POST':
        # check if the post request has the file part
        if 'file' not in request.files:
            flash('No file part')
            return redirect(request.url)
        file = request.files['file']
        # if user does not select file, browser also
        # submit an empty part without filename
        if file.filename == '':
            flash('No selected file')
            return redirect(request.url)
        if file and allowed_file(file.filename):
            # filename = secure_filename(file.filename)
            input_image = file.read()
            payload = {
                "instances": [{'bytes_data': {"b64": base64.b64encode(input_image).decode("utf-8")}}]
            }

            r = requests.post('http://localhost:9000/v1/models/ImageCLF:predict', json=payload)

            result = r.content.decode('utf-8')
            if 'predictions' in result:
                results = [{'name': result_map[json.loads(result)['predictions'][0].index(prediction)], 'percentage':
                           round(prediction * 100, 2)} for prediction in json.loads(result)['predictions'][0]
                           if round(prediction * 100, 2) > 0]

                return jsonify(sorted(results, key=lambda i: i['percentage'], reverse=True))

    return '''
    <!doctype html>
    <title>Upload new File</title>
    <h1>Upload new File</h1>
    <form method=post enctype=multipart/form-data>
      <input type=file name=file>
      <input type=submit value=Upload>
    </form>
    '''


if __name__ == "__main__":
    app.run(host=host, port=port, debug=debug)
