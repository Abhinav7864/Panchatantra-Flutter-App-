# Panchatantra-Flutter-App-

An adaptive, source-grounded Panchatantra storytelling and moral reasoning Flutter application for children with in-app voice cloning and interactive in-video checkpoints.

---

## 🌟 Key Features

1. **Child-Friendly Interactive UI:**
   - Designed with pastel sky blue clouds, royal purple curved headers, search pills, category chips, and 2×2 learning adventure cards (Reading, Numbers, Drawing, Puzzles).

2. **4-Step Parent & Child Onboarding Flow:**
   - **Step 1:** Parent Profile & Values (Name, Relationship, Learning Objective).
   - **Step 2:** **Direct In-App Voice Cloning** (Sound wave visualizer, audio recorder, live enrollment, and voice preview).
   - **Step 3:** Child Profile (Name, Animal Avatar, Age slider 4–15 selecting appropriate Flesch-Kincaid reading complexity).
   - **Step 4:** Curriculum Activation & Baseline Elo calibration.

3. **Interactive Animated Video Player with 5 In-Video Checkpoints:**
   - Plays Full HD (1080p) animated Panchatantra story (*"The Lion and the Clever Rabbit"*).
   - Pauses at 5 narrative cue-points:
     - **Q1 (42s):** Video Recall (Antagonist — The fierce King Lion).
     - **Q2 (92s):** Video Recall (Protagonist — The clever little rabbit).
     - **Q3 (142s):** Child Development & Empathy (*Dhairya* / Staying calm under pressure).
     - **Q4 (192s):** Moral Reasoning Dilemma (*Dharma* / Situational ethics).
     - **Q5 (230s):** Developmental Life Application (*Niti* / Calmer, smarter problem solving).

4. **Multi-Dimension Elo Skill Engine:**
   - Tracks 6 skill dimensions: Comprehension Recall ($C_1$), Structural Sequencing ($C_2$), Character Motives ($C_3$), Moral Empathy ($M_1$), Ethics Dilemmas ($M_2$), and Real-World Application ($M_3$).
   - Dynamic difficulty adjustment and live score updates.

5. **Integrated Voice Cloning Engine:**
   - Located in [`voice_clone_engine/`](voice_clone_engine/).
   - Zero-shot neural formant shifting and acoustic pitch matching for zero-cost, private parent voice synthesis.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.24+ recommended)
- Python 3.9+ (for optional local voice cloning server)

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/Abhinav7864/Panchatantra-Flutter-App-.git
   cd Panchatantra-Flutter-App-
   ```

2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   - **On Web (Google Chrome):**
     ```bash
     flutter run -d chrome
     ```
   - **On Native macOS:**
     ```bash
     flutter run -d macos
     ```

### (Optional) Run Local Voice Cloning Server
To enable real-time local voice synthesis via REST API:
```bash
python3 voice_clone_engine/voice_server.py
```

---

## 📂 Project Structure
```
├── lib/
│   ├── main.dart
│   ├── models/           # Story models, Elo skill metrics, user profiles
│   ├── providers/        # App state management (Provider)
│   ├── screens/          # Splash, Onboarding, Video player, Celebration, Dashboard
│   ├── services/         # Elo engine, Voice clone runner, Story generator
│   └── theme/            # Child-friendly pastel colors, text styles
├── assets/
│   ├── audio/            # Cloned voice previews
│   └── videos/           # 1080p Panchatantra animated story video
├── voice_clone_engine/   # Python voice cloner and REST microservice
├── scripts/              # Video & story generation utilities
├── test/                 # Automated Flutter widget & unit tests
└── pubspec.yaml
```

---

## 📜 License
MIT License.
