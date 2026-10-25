import '../domain/models/educational_tip.dart';

class CuratedTips {
  CuratedTips._();

  static const List<EducationalTip> allTips = [
    EducationalTip(
      id: 'tip_cycle_basics',
      title: 'The Menstrual Cycle is More Than Just the Period',
      summary: 'A monthly cycle involves four distinct physiological phases with shifting hormone levels.',
      fullContent:
          'While the bleed (menstruation) is the most visible phase, a menstrual cycle spans four distinct phases: '
          'Menstrual (uterine lining sheds), Follicular (follicles develop, estrogen rises), '
          'Ovulation (egg release, brief mid-cycle window), and Luteal (progesterone rises then drops if no pregnancy occurs). '
          'Energy levels, metabolism, social appetite, and comfort naturally fluctuate across these phases. '
          'Understanding these rhythms allows partners to offer attentive, calibrated support.',
      category: TipCategory.cycleUnderstanding,
      actionablePoints: [
        'Notice that energy levels often rise post-period and drop in late luteal phase.',
        'Avoid treating cycle shifts as illnesses; they are healthy biological processes.',
        'Remember that each person experiences their cycle uniquely.',
      ],
    ),
    EducationalTip(
      id: 'tip_natural_variability',
      title: 'Why 28-Day Cycles Are a Textbook Average, Not a Rule',
      summary: 'Normal, healthy cycles can range from 21 to 38 days, and vary month-to-month.',
      fullContent:
          'Pop culture often repeats that menstrual cycles are strictly 28 days long. In reality, medical research shows '
          'that healthy adult cycles normally range between 21 and 38 days, and can vary by several days between months. '
          'Illness, travel, stress, sleep disruption, and exercise can shift ovulation timing. '
          'This is why cycle tracking apps offer estimates rather than exact mathematical certainty.',
      category: TipCategory.predictionUncertainty,
      actionablePoints: [
        'Do not worry or react with alarm if her period begins a few days early or late.',
        'Never treat cycle estimates as contraception or fertility guarantees.',
        'Recognize that apps predict probabilities, not calendar absolutes.',
      ],
    ),
    EducationalTip(
      id: 'tip_heat_therapy',
      title: 'The Calming Power of Heat Therapy for Cramps',
      summary: 'Heat relaxes smooth muscle tissue and brings genuine relief to abdominal tension.',
      fullContent:
          'Menstrual cramps (dysmenorrhea) are caused by prostaglandin hormones prompting uterine contractions to shed lining. '
          'Applying gentle topical heat—such as a hot water bottle, warm compress, or heating pad—causes vasodilation, '
          'increasing local blood flow and directly relaxing tight smooth muscle tissues. '
          'Studies show heat therapy can be as effective as mild over-the-counter pain relief for abdominal discomfort.',
      category: TipCategory.physicalComfort,
      actionablePoints: [
        'Offer a heated blanket, heating pad, or warm water bottle proactively.',
        'Ensure the temperature is warm and soothing without risking skin burns.',
        'Combine heat therapy with gentle lumbar pillow support.',
      ],
    ),
    EducationalTip(
      id: 'tip_active_listening',
      title: 'Holding Space: Listening vs. Solving',
      summary: 'Often, the greatest emotional gift is listening patiently without rushing to fix.',
      fullContent:
          'When your partner shares feelings of fatigue, emotional sensitivity, or frustration, an intuitive reflex '
          'for many partners is to immediately propose logical fixes. While well-intentioned, this can feel invalidating. '
          'More often, what is truly needed is emotional safety: feeling heard, respected, and comforted without judgment. '
          'A simple question like "Would you like me to listen, give advice, or just hold you?" works wonders.',
      category: TipCategory.emotionalSupport,
      actionablePoints: [
        'Ask: "Do you want comfort, solutions, or space?"',
        'Validate her feelings instead of debating their root cause.',
        'Never dismiss her experiences by attributing everything to hormones.',
      ],
    ),
    EducationalTip(
      id: 'tip_respectful_language',
      title: 'Respectful Language & Avoiding Harmful Tropes',
      summary: 'Never dismiss her thoughts, boundaries, or emotions with "Is it that time of the month?"',
      fullContent:
          'Reducing a woman’s legitimate boundaries, anger, sadness, or fatigue to "hormones" or "PMS" can feel deeply '
          'dismissive and disrespectful. While hormonal fluctuations certainly affect physical and mental stamina, '
          'her feelings, thoughts, and opinions remain fully valid. Treat her with dignity, honor her communication, '
          'and never use cycle tracking to undermine her voice or autonomy.',
      category: TipCategory.respectfulCommunication,
      actionablePoints: [
        'Never weaponize cycle phases during disagreements or discussions.',
        'Respect her privacy: record only details she has voluntarily chosen to share.',
        'Acknowledge her emotional experiences as genuine and real.',
      ],
    ),
    EducationalTip(
      id: 'tip_supply_stocking',
      title: 'Building a Thoughtful Care Kit at Home and On-the-Go',
      summary: 'Anticipate practical essentials so she never faces an unexpected shortage.',
      fullContent:
          'Knowing which specific pads, tampons, or menstrual cups she prefers—and having them readily stocked in '
          'your shared bathroom, car glove compartment, or travel bag—is one of the most practical and appreciated gestures '
          'a partner can make. Take note of brand preferences, absorbency levels, and whether she prefers unscented items.',
      category: TipCategory.practicalEssentials,
      actionablePoints: [
        'Save her preferred brands and absorbencies in the Notes section.',
        'Check the cabinet 2-3 days before the estimated period window.',
        'Keep spare supplies and pain-relief options discretely available in travel kits.',
      ],
    ),
    EducationalTip(
      id: 'tip_medical_boundaries',
      title: 'When to Encourage Professional Medical Advice',
      summary: 'HerCare is a companion tool, not a diagnostic or healthcare provider.',
      fullContent:
          'While common symptoms like mild cramping, bloating, and fatigue are ordinary aspects of menstrual cycles, '
          'severe, debilitating pelvic pain, excessive bleeding, sudden fainting, or chronic severe depression (PMDD) '
          'are not things to simply "tough out". If she expresses feeling unusually severe pain or concern, '
          'calmly and gently encourage her to discuss her symptoms with a qualified physician or gynecologist.',
      category: TipCategory.physicalComfort,
      actionablePoints: [
        'Do not attempt to medically diagnose PMS, PMDD, or gynecological conditions.',
        'Support her in booking an appointment or attending a clinic visit if she desires.',
        'Offer unconditional emotional comfort while seeking proper medical care.',
      ],
    ),
  ];
}

