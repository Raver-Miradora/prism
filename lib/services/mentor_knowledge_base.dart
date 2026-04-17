/// Static knowledge repository for the PRISM Mentor.
/// Contains keyword-triggered responses and follow-up suggestions.
class MentorKnowledgeBase {
  static const Map<List<String>, Map<String, dynamic>> knowledgeGraph = {
    // ── OJT ACADEMY MODULES ──────────────────────────────────────────────────

    ['personality', 'dress code', 'grooming', 'hygiene']: {
      'response': 'Interns must maintain a **professional appearance**. Practice good **personal hygiene**, wear the official **LGU/school uniform** or **smart casual** attire as prescribed, and carry yourself with confidence and courtesy.',
      'suggestions': ['Dress Code', 'Grooming Tips', 'Office Etiquette'],
    },

    ['communication', 'talking', 'listening', 'phone', 'disrespect']: {
      'response': '**Communication** is a two-way process. Practice **active listening**, maintain eye contact, and speak clearly. When answering office phones, always state your **department and name** clearly. Avoid using slang or informal language with supervisors.',
      'suggestions': ['Phone Etiquette', 'Active Listening', 'Email Tips'],
    },

    ['writing', 'letter', 'memo', 'email', 'transmittal', 'nar format', 'narrative report']: {
      'response': 'Official LGU communications must be **clear, concise, and courteous** (The 3 Cs). Always double-check spelling and grammar. **Transmittal letters** must clearly state the recipient, the subject, and list all attached documents. For **Narrative Reports**, focus on day-to-day accomplishments and learning outcomes.',
      'suggestions': ['HRMO Addressee', 'Letter Format', 'Writing Module'],
    },

    ['stress', 'overwhelmed', 'tired', 'burnout', 'mental health']: {
      'response': 'It is normal to feel **stressed**. Manage it by practicing proper **time management**, breaking large tasks into smaller ones, and taking deep breaths. Do not hesitate to ask your supervisor (**Ma\'am Nimfa**) for clarification if you are overwhelmed.',
      'suggestions': ['Time Management', 'Mental Health', 'Contacting HRMO'],
    },

    ['sexual harassment', 'uncomfortable', 'touching', 'jokes', 'safe space', 'gad']: {
      'response': 'The LGU maintains a **ZERO-TOLERANCE** policy for sexual harassment (**RA 7877** & **Safe Spaces Act**). This includes unwelcome sexual advances, inappropriate jokes, or uninvited physical contact. If you experience this, report it immediately to the **HRMO**.',
      'suggestions': ['Report Incident', 'Safe Spaces Act', 'HRMO Location'],
    },

    ['safety', 'hazard', 'accident', 'emergency', 'fire', 'ergonomics', 'osh']: {
      'response': 'Always prioritize **safety**. Report any **hazards** (like exposed wires or wet floors) to your supervisor. Practice good **ergonomics** by sitting properly at your desk. Familiarize yourself with the LGU\'s **fire exits** and evacuation plans.',
      'suggestions': ['Fire Exits', 'Ergonomics Tips', 'Reporting Hazards'],
    },

    ['work ethic', 'attitude', 'integrity', 'late', 'punctual', 'teamwork']: {
      'response': 'A strong **work ethic** involves **punctuality, integrity, and responsibility**. Arrive on time, do not falsify your **DTR**, take initiative when you finish tasks early, and respect your co-workers.',
      'suggestions': ['DTR Rules', 'Punctuality', 'Taking Initiative'],
    },

    // ── INTERNSHIP REQUIREMENTS ──────────────────────────────────────────────
    
    ['ojt requirements', 'ojt checklist', 'ojt folder', 'immersion requirements', 'immersion checklist', 'immersion folder']: {
      'response': 'For **OJT**, your **1st Folder** needs: Endorsement Letter, Application Letter, Resume/CV, and MOA. Your **2nd Folder** (Clearance) needs: DTR, Accomplishment Report, Narrative Report, Certificate of Completion, and Evaluation Form.',
      'suggestions': ['DTR Rules', 'Generating PDF', 'Narrative Report'],
    },

    ['spes requirements', 'spes checklist', 'spes folder']: {
      'response': 'For **SPES**, your **1st Folder** needs: SPES Application Form, Birth Certificate, Copy of Grades, and Indigency Certificate. Your **2nd Folder** (Clearance) needs: DTR, Accomplishment Report, and Payroll.',
      'suggestions': ['SPES Salary', 'SPES Guidelines', 'HRMO Location'],
    },

    // ── LGU & APP PROCEDURES ─────────────────────────────────────────────────

    ['spes', 'special program', 'student employment', 'spes salary', 'stipend', 'payroll']: {
      'response': 'For **SPES**, employment lasts 20 to 78 days. **DOLE** shoulders 40% of your salary, while **LGU Lagonoy** pays the remaining 60%. \n\n*Note: You must maintain passing grades to stay in the program.*',
      'suggestions': ['SPES Salary', 'SPES Requirements', 'DTR Rules'],
    },

    ['gip', 'government internship', 'stipend']: {
      'response': 'The **GIP** lasts 3 to 6 months. You receive a stipend equivalent to **75% of the minimum wage**. \n\n*Civil Service eligibility is NOT required to participate.*',
      'suggestions': ['GIP Stipend', 'Civil Service Rules', 'DTR Rules'],
    },

    ['ojt', 'immersion', 'practicum']: {
      'response': '**OJT** and **Work Immersion** hours depend on your school\'s curriculum—usually **300 to 480 hours**. While unpaid, the experience credits towards your graduation requirements.',
      'suggestions': ['OJT Hours', 'Journal Entry', 'Target Hours'],
    },

    ['dtr', 'excess', 'overtime', 'undertime', 'csc', 'hours']: {
      'response': 'Under **CSC rules**, standard shifts are 8 hours. **Excess minutes** are NOT officially credited as overtime. However, **undertime** (late arrivals or early departures) is strictly deducted.',
      'suggestions': ['Undertime Rules', 'Generating PDF', 'Manual Clocking'],
    },

    ['transmittal', 'letter', 'format', 'hrmo']: {
      'response': 'Transmittal letters to the HRMO should be addressed to:\n\n**Ma\'am Nimfa M. Peñas, HRMO**\n\nInclude a bulleted list of attached docs and a **\'Received By\'** signature block.',
      'suggestions': ['HRMO Addressee', 'Letter Format', 'Writing Module'],
    },

    ['absent', 'leave', 'sick', 'excuse']: {
      'response': 'If you are absent, use the **\'Log Absence/Leave\'** button on your dashboard. For prolonged absences, submit an **excuse letter** to the HRMO upon your return.',
      'suggestions': ['Excuse Letter', 'Log Absence', 'Target Hours'],
    },

    ['prism app', 'generate', 'clock', 'pdf', 'save', 'how to']: {
      'response': 'In **PRISM**:\n- **Clock In/Out**: Slide right on the digital clock.\n- **Reports**: Tap \'Generate Accomplishment Report\' in the Journal tab.',
      'suggestions': ['Generating PDF', 'Clocking Help', 'Timesheet Info'],
    },

    ['hi', 'hello', 'hey', 'greetings', 'morning', 'afternoon', 'evening']: {
      'response': '👋 Hello! I am your **PRISM Mentor**. I can help with **LGU rules**, **DTR procedures**, and **OJT Academy modules**. What would you like to know about?',
      'suggestions': ['DTR Rules', 'Dress Code', 'OJT Academy Info', 'Generating PDF'],
    },
  };
}
