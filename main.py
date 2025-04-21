import logging
from flask import Flask, request, jsonify
import threading
from tkinter import Tk, Label, messagebox

app = Flask(__name__)

APPNAME ="TeraAutoBPJS" 
PORT = 8087
SERVICE_STATUS = f"{APPNAME} is Using Port {PORT}"
SERVER_RUNNING = False
SERVER_THREAD = None

def is_readable(filename):
    try:
        with open(filename, 'r') as f:
            return True
    except Exception as e:
        return False

@app.route('/', methods=['GET'])
def service_status():
    return jsonify({'status': SERVICE_STATUS})

@app.route('/auto-bpjs', methods=['POST'])
def autoprint_pdf():
    try:
        automate = request.form.get('automate')
        if not automate:
            return jsonify({'error': True, 'msg': 'Failed to Execute Automation', 'hint': 'params error: invalid automate'}), 400

        keysearch = request.form.get('keysearch')
        if not keysearch:
            return jsonify({'error': True, 'msg': 'Failed to Execute Automation', 'hint': 'params error: invalid keysearch'}), 400

        program = f'./{APPNAME}.exe'
        args = [];
        args.extend([f"{automate}", f"{keysearch}"])

        logging.info(f'keysearch: {keysearch}')
        logging.info(f'args: {args}')

        import subprocess
        p = subprocess.Popen([program] + args)
        p.wait()
        logging.info(f'p.args: {p.args}')

        return jsonify({'error': False, 'msg': 'Automation activated'}), 200

    except Exception as e:
        logging.error(str(e))
        return jsonify({'error': True, 'msg': 'failed to Execute Automation', 'hint': 'failed to execute print command'}), 500

def start_server():
    global SERVER_RUNNING, SERVER_THREAD
    if not SERVER_RUNNING:
        try:
            SERVER_THREAD = threading.Thread(target=app.run, kwargs={'host': '0.0.0.0', 'port': PORT, 'debug': False})
            SERVER_THREAD.daemon = True  # Set as daemon thread
            SERVER_THREAD.start()
            SERVER_RUNNING = True
            status_label.config(text=f"Server Started")
            info_label.config(text=f"Server is running on port {PORT}")
        except Exception as e:
            messagebox.showerror("Error", f"Failed to start server: {e}")

def on_closing():
    window.destroy()

# Create main window
window = Tk()
window.title("TeraPythonPrint Service")
window.geometry("300x150")  # Set window width to 300 and height to 150

# Status Label
status_label = Label(window, text="Server Stopped", font=("Arial", 14))
status_label.pack(pady=10)

# Status Label
info_label = Label(window, text="", font=("Arial", 14))
info_label.pack(pady=10)

# Status Label
creator_label = Label(window, text=f"github.com/teraihsan/{APPNAME}", font=("Arial", 8))
creator_label.pack(pady=10)

# Bind on_closing function to WM_DELETE_WINDOW event
window.protocol("WM_DELETE_WINDOW", on_closing)

# Run the GUI
window.wait_visibility()
start_server()
window.mainloop()

if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    logging.getLogger().setLevel(logging.INFO)