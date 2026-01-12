from flask import Flask, render_template

app = Flask(__name__)

@app.route("/")
def profile():
    user = {
        "name": "Taiwo Bello",
        "role": "Cloud / DevOps Engineer",
        "email": "taiwo@example.com",
        "skills": ["AWS", "Kubernetes", "Docker", "Terraform"]
    }
    return render_template("profile.html", user=user)

if __name__ == "__main__":
    app.run(debug=True)