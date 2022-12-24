import logging
import os

from flask import Flask, redirect, url_for, render_template

app = Flask(__name__)

logger = logging.getLogger('werkzeug')
handler = logging.FileHandler('./logs/hw-app.log')
logger.addHandler(handler)


logger.log(30,"Logging environment variable: %s", os.environ.get('HW_ENV_VAR'))


@app.route("/")
def hello():
   #return "Hello World!"
   return render_template('index.html', user="", env_var=os.environ.get('HW_ENV_VAR'))

@app.route('/admin')
def hello_admin():
   #return "Hello Admin!"
   return render_template('admin.html', user="Admin", env_var=os.environ.get('HW_ENV_VAR'))

@app.route('/guest/<guest>')
def hello_guest(guest):
   #return "Hello %s as Guest" % guest
   return render_template('guest.html', user=guest, env_var=os.environ.get('HW_ENV_VAR'))

@app.route('/user/<name>')
def hello_user(name):
   if name =='admin':
      return redirect(url_for('hello_admin'))
   else:
      return redirect(url_for('hello_guest',guest = name))
