from flask import Flask
app = Flask('first-app')
@app.route('/')
def hello():
  return "Hello World! Lets sail together - prod.\n"
if __name__ == '__main__':
  app.run(host = '0.0.0.0', port = 8080)