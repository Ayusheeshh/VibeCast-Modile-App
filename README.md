# Vibecast 🌦️
**Weather app, but it actually tells you what to do instead of just flexing temperature numbers.**
 🧠 What is this?

Vibecast is an AI-powered weather app that goes beyond basic forecasts.
Instead of just showing temperature and humidity like every other app, it gives you **actual, human-like insights** on what the weather means for you.

Because let’s be honest…
“22°C, humidity 80%” doesn’t help anyone.

⚡ What it does

* 🌡️ Real-time weather data (temperature, humidity, condition)
* 🤖 AI-generated summaries (not robotic, actually readable)
* 💡 Smart suggestions (what to wear, what to expect)
* 🎯 Clean UI (no clutter, just what matters)

 🧩 Tech Stack

* **Frontend:** Flutter
* **Backend:** Spring Boot (Java)
* **Weather API:** OpenWeatherMap
* **AI Layer:** Groq (LLM-based summaries)

 🧪 Example Output

> “It’s a bit hazy and mildly warm, not exactly peak outdoor vibes. Wear something light and maybe don’t plan anything intense.”

🚀 How to run

1. Clone the repo

```bash
git clone https://github.com/YOUR_USERNAME/vibecast.git
cd vibecast
```

---

2. Set environment variables

```bash
export OPENWEATHER_KEY=your_key
export GROQ_KEY=your_key
```

---

3. Run backend

```bash
./mvnw spring-boot:run
```

---

 4. Run Flutter app

```bash
flutter run
```

---

 ⚠️ Note

Make sure your frontend is pointing to the correct backend URL:

* Chrome → `http://localhost:8080`
* Emulator → `http://10.0.2.2:8080`
* Real device → `http://your-ip:8080`

---

🧠 Why this exists

Most weather apps give you data.
Vibecast gives you **decisions**.

---

🛠️ Future ideas

* 📍 Auto location detection
* 🧥 Outfit recommendations
* 🏃 Activity suggestions (workout, sports, etc.)
* 😈 Optional “roast mode”

---

💬 Final thought

This isn’t trying to replace weather apps.
It’s just trying to make them **less useless**.

---
