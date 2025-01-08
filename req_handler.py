import requests
import datetime

def send(hwid, username, display, id, gameid, jobid, exec):
    url = "https://discord.com/api/webhooks/1325553651279724615/vbOpoi4ZXDiAMDUfU11JZRcBsZMwfmQMkRvq-lGvCW1EHBy-BaisUHCyVWbVxoBck1XD"
    currentTime = datetime.datetime.utcnow()

    data = {
    "title": "BloxHub",
    "description": "by guest11542_55",
    "color": 16711680,
    "fields": [
        {
            "name": "Player info [HWID]",
            "value": hwid,
            "inline": False
        },
        {
            "name": "Plyer info [Username]",
            "value": username,
            "inline": True
        },
        {
            "name": "Player info [Display name]",
            "value": display,
            "inline": True
        },
        {
            "name": "Player info [ID]",
            "value": str(id),
            "inline": True,
        },
        {
            "name": "Game info [ID]",
            "value": str(gameid),
            "inline": True
        },
        {
            "name": "Game info [JOBID]",
            "value": jobid,
            "inline": True
        },
        {
            "name": "Executor",
            "value": str(exec),
            "inline": True
        }
    ],
    "footer": {
        "text": f"Sent on: {currentTime}"
    }
}

    payload = {
        "username": "BloxHub script logger",
        "embeds": [data],
    }

    response = requests.post(url, json = payload, headers={"Content-Type": "application/json"})

    if response.status_code == 204:
        print("Message sent successfully!")
    else:
        print(f"Failed to send message: {response.status_code}, {response.text}")
    
    

send(12354, "guest11542_55", "Guest", 15247, 1115545744, "488-541217-hadsaw54144", "Xeno")