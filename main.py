from flask import Flask, request, render_template, redirect
from os import getenv
import pymysql


app = Flask(__name__, template_folder='html/')

PORT = getenv("PORT", "8080")
DB_HOST = getenv("DB_HOST", "mysql")
DB_PORT = int(getenv("DB_PORT", 3306))
DB_USER = getenv("DB_USER", "user")
DB_PASSWORD = getenv("DB_PASSWORD", "password")
DB_NAME = getenv("DB_NAME", "ips")

db = pymysql.connect(host=DB_HOST, port=DB_PORT, database=DB_NAME, user=DB_USER, password=DB_PASSWORD)

cursor = db.cursor()
cursor.execute("select version()")
data = cursor.fetchone()

query = "CREATE TABLE IF NOT EXISTS iplist (id int not null auto_increment, ip text, primary key (id) )"
cursor.execute(query)
cursor.connection.commit()


@app.route('/', methods = ['GET'])
def redirect_to():
    return redirect('/client-ip')

@app.route('/client-ip/', methods = ['GET'])
@app.route('/client-ip', methods = ['GET'])
def record_client_ip():
    clientip = request.remote_addr
    query = "INSERT INTO iplist(id, ip) values('%s', '%s')" % (0, clientip)
    cursor.execute(query)
    db.commit()
    return "<h1>Client IP: '"+ clientip +"' recorded successfully!<h1>"

@app.route('/client-ip/list/', methods = ['GET'])
@app.route('/client-ip/list', methods = ['GET'])
def fetch_list():
    query = "select * from iplist"
    cursor.execute(query)
    data = cursor.fetchall()
    return render_template("list.html", data=data)

