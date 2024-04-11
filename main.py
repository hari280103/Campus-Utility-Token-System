


# version -3
    
from flask import Flask, request, jsonify, render_template, redirect, url_for
from flask_login import LoginManager, UserMixin, login_user, login_required, logout_user, current_user
from web3 import Web3
from flask_cors import CORS
from pymongo import MongoClient

app = Flask(__name__)
app.config["SECRET_KEY"] = "your_secret_key"  # Replace with a secret key for session management

login_manager = LoginManager(app)
login_manager.login_view = 'login'

CORS(app)

# MongoDB configuration
client = MongoClient("mongodb://localhost:27017/")
db = client["your_database_name"]
transactions_collection = db["transactions"]

class Admin(UserMixin):
    def __init__(self, username, password):
        self.id = username
        self.password = password

@login_manager.user_loader
def load_user(username):
    # Check if the username is 'admin', and use a default password
    if username == 'admin':
        return Admin('admin', 'admin123')
    return None

# Connect to Ganache
ganache_url = "http://127.0.0.1:7545"
web3 = Web3(Web3.HTTPProvider(ganache_url))

# Check if connected to Ganache
if not web3.is_connected():
    raise ValueError("Error: Could not connect to Ganache")

# Default college account
college_account = "0x913407744055C3ee1292Ec9a157A6c9EE29323eD"

@app.route('/initiateTransaction', methods=['POST'])
def initiate_transaction():
    try:
        student_name = request.form['studentName']
        roll_number = request.form['rollNumber']
        academic_year = request.form['academicYear']
        branch = request.form['branch']
        student_account = request.form['studentAccount']
        amount_ether = float(request.form['amountEther'])
        private_key = request.form['privateKey']

        # Convert amount to Wei
        amount_wei = web3.to_wei(amount_ether, "ether")

        # Create a transaction
        transaction = {
            "from": student_account,
            "to": college_account,
            "value": amount_wei,
            "gas": 2000000,
            "gasPrice": web3.to_wei("50", "gwei"),
            "nonce": web3.eth.get_transaction_count(student_account),
        }

        # Sign and send the transaction
        signed_transaction = web3.eth.account.sign_transaction(transaction, private_key)
        transaction_hash = web3.eth.send_raw_transaction(signed_transaction.rawTransaction)

        # Store data in MongoDB
        transaction_data = {
            "from": student_account,
            "studentName": student_name,
            "rollNumber": roll_number,
            "academicYear": academic_year,
            "branch": branch,
            "studentAccount": student_account,
            "amountEther": amount_ether,
            "privateKey": private_key,
            "transactionHash": transaction_hash.hex(),
        }
        transactions_collection.insert_one(transaction_data)

        current_balance = web3.eth.get_balance(student_account)

        response_data = {
            "message": f"Transaction sent! Transaction Hash: {transaction_hash.hex()}",
            "available_balance": web3.from_wei(current_balance, 'ether')
        }

        return jsonify(response_data)
    except Exception as e:
        return jsonify(error=str(e))

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        user = Admin(username, password)

        if user and user.password == password:
            login_user(user)
            return jsonify(message='Login successful!')
        else:
            return jsonify(error='Invalid credentials')
    return render_template('login.html')

# Update the /admin_panel route
@app.route('/admin_panel')
@login_required
def admin_panel():
    # Fetch all fields from the MongoDB collection
    transactions = transactions_collection.find({}, {'_id': 0})

    return render_template('admin_panel.html', current_user=current_user, transactions=transactions)


@app.route('/logout')
@login_required
def logout():
    logout_user()
    return jsonify(message='Logout successful!')

if __name__ == '__main__':
    app.run(debug=True)
