import '../models/story_model.dart';
import '../models/quiz_model.dart';

class StoryService {
  static final List<Story> allStories = [
    Story(
      storyId: 'PT001',
      title: 'The Lion and the Clever Rabbit',
      tantraBook: 'Book 1: Mitra-bheda (The Loss of Friends)',
      ageBand: '4-9',
      readingMinutes: 8,
      cognitiveLevel: 3,
      coverEmoji: '🦁',
      summary: 'A tiny rabbit uses his wits to trick a ferocious lion and save all the forest animals.',
      adaptedText: '''Deep in a green forest, there lived a mighty lion named Bhasuraka. He was strong and fierce. Every day, he hunted many animals, more than he could ever eat.

The scared animals held a council under the great Banyan tree. They sent a message to the lion: "O King of the forest! Please do not kill all of us at once. Each day, one animal will come to your cave for your meal." The lion agreed.

One day, it was the turn of a little rabbit. The rabbit did not want to die. As he hopped along slowly, he thought of a clever plan.

When the rabbit reached the cave, the sun was setting. The lion was starving and roaring with great fury: "Why are you so late, little creature? And why did they send only one tiny rabbit?"

The rabbit bowed politely and said: "O King! Five rabbits were sent to you. But on the way, another ferocious lion stopped us. He claimed he is the true king of the forest! He ate the other four rabbits. I ran away to warn you!"

The lion roared: "Show me this impostor right now! I will tear him apart!"

The clever rabbit led the angry lion to a deep stone well filled with clear water. "He is hiding inside this fortress, King!" the rabbit whispered.

The lion peeked over the stone ledge. Deep in the water, he saw his own reflection with a bushy mane and roaring teeth! Thinking it was his rival, the lion let out a thunderous roar. The deep well echoed the roar right back at him.

Enraged, the lion leapt into the well to attack his enemy. Splash! He fell deep into the water and drowned. The clever little rabbit hopped back happily and told all the forest animals that they were finally free.''',
      originalSourceCitation: 'Arthur W. Ryder (1925), Purnabhadra recension 1199 CE, Book 1, Story 8',
      moral: 'Intelligence and wisdom can overcome raw brute strength.',
      iksConcept: 'Niti (Strategic Wisdom) & Dharma (Protection of Life)',
      iksExplanation: 'In Indian Knowledge Systems, Niti teaches that physical force is blind without strategic discernment (Buddhi). The rabbit acted not out of malice, but to uphold Dharma by protecting the innocent community.',
      characters: ['Bhasuraka the Lion', 'The Clever Rabbit', 'Forest Animals'],
      themes: ['Strategy', 'Courage', 'Protection', 'Wisdom'],
      glossary: {
        'Foliage': 'Plant leaves collectively covering forest trees.',
        'Council': 'A meeting where leaders gather to discuss and solve problems.',
        'Impostor': 'A person or creature pretending to be someone else.',
        'Reflection': 'The image of something you see in water or a mirror.',
        'Dharma': 'The ancient Sanskrit principle of righteous action and duty.',
      },
      skillWeights: {
        'C1_recall': 0.8,
        'C2_sequence': 0.7,
        'C3_motive': 0.9,
        'M1_perspective': 0.85,
        'M2_moral_dilemma': 0.75,
        'M3_niti_strategy': 0.95,
      },
      discussionPrompt: 'How do you think the little rabbit felt when the lion roared? Would you have tried to trick the lion or run away?',
      questions: [
        QuizQuestion(
          id: 'PT001-Q1',
          prompt: 'Why was the lion furious when the rabbit arrived at his cave?',
          skill: 'C1_recall',
          options: [
            'The rabbit brought sour berries',
            'The rabbit arrived very late and was tiny',
            'The rabbit was accompanied by a hunter',
            'The lion wanted to sleep',
          ],
          correctIndex: 1,
          explanation: 'The rabbit purposely arrived late near sunset so the hungry lion would be impatient and act without thinking.',
        ),
        QuizQuestion(
          id: 'PT001-Q2',
          prompt: 'What did the lion actually see inside the deep well?',
          skill: 'C3_motive',
          options: [
            'A giant crocodile waiting to fight',
            'A shiny gold treasure chest',
            'His own reflection in the clear water',
            'The rabbit hiding behind a rock',
          ],
          correctIndex: 2,
          explanation: 'The lion saw his own reflection in the water and mistook it for an enemy lion because his anger blinded his reasoning.',
        ),
        QuizQuestion(
          id: 'PT001-Q3',
          prompt: 'Which quality helped the rabbit save the entire forest?',
          skill: 'M3_niti_strategy',
          options: [
            'Physical strength and sharp claws',
            'Quick wit and thoughtful strategy (Niti)',
            'Running faster than all animals',
            'Finding magical weapons',
          ],
          correctIndex: 1,
          explanation: 'The Panchatantra emphasizes that wisdom and clever thinking triumph over sheer physical power.',
        ),
      ],
    ),

    Story(
      storyId: 'PT002',
      title: 'The Monkey and the Crocodile',
      tantraBook: 'Book 4: Labdhapranasam (Loss of Gains)',
      ageBand: '4-9',
      readingMinutes: 10,
      cognitiveLevel: 2,
      coverEmoji: '🐒',
      summary: 'A friendly monkey shares delicious berries with a crocodile, but must use his presence of mind when betrayed.',
      adaptedText: '''On the banks of a sparkling river stood a grand Rose-Apple tree laden with sweet red berries. In this tree lived a merry monkey named Raktamukha.

One afternoon, a crocodile named Karalamukha crawled out of the river to rest on the warm sand. The friendly monkey called down: "You look weary, friend! Taste these sweet rose-apples." The monkey tossed down a bunch of ripe fruit.

The crocodile loved the delicious apples. From that day on, the monkey and the crocodile met every afternoon. They chatted about the forest and shared fruit.

One day, the crocodile took some sweet apples home to his wife. His wife tasted them and said: "If this monkey eats such divine fruits every day, his heart must be sweet as nectar! Bring me his heart, or I will not speak to you again!"

The crocodile was torn. He loved his friend, but he could not say no to his wife. The next day, he invited the monkey: "Dear friend, my wife wishes to thank you with a feast. Come across the river on my back!"

The monkey hopped onto the crocodile's back. When they reached midstream where the water was deep and turbulent, the crocodile confessed sadly: "Forgive me, friend. My wife wants your sweet heart to eat."

The monkey was terrified, but he did not panic. He smiled calmly and said: "Why didn't you tell me earlier, brother? Monkeys keep their hearts safely stored in the hollow of their trees! Turn around quickly so I can fetch my heart for your wife."

The foolish crocodile believed him and swam back to the shore. The instant they touched the riverbank, the monkey leaped high into the tall tree.

"O foolish crocodile!" called the monkey from above. "Can any creature live without a heart? Our friendship ends here. True friends never betray each other."''',
      originalSourceCitation: 'Arthur W. Ryder (1925), Book 4, Fable 1',
      moral: 'Presence of mind in danger saves life; false friends must be discarded.',
      iksConcept: 'Mitra-bheda (Testing Friendship) & Viveka (Discernment)',
      iksExplanation: 'Panchatantra warns that blind trust without discernment leads to danger. True friendship is built on mutual respect, not opportunistic exploitation.',
      characters: ['Raktamukha the Monkey', 'Karalamukha the Crocodile', 'Crocodile Wife'],
      themes: ['Friendship', 'Presence of Mind', 'Trust', 'Wisdom'],
      glossary: {
        'Laden': 'Heavily loaded or full of fruit.',
        'Turbulent': 'Moving unevenly and violently.',
        'Confessed': 'Admitted a secret or wrong action.',
        'Viveka': 'The Sanskrit concept of inner discernment between right and wrong.',
      },
      skillWeights: {
        'C1_recall': 0.7,
        'C2_sequence': 0.8,
        'C3_motive': 0.9,
        'M1_perspective': 0.9,
        'M2_moral_dilemma': 0.85,
        'M3_niti_strategy': 0.8,
      },
      discussionPrompt: 'What would you do if a friend asked you to do something you knew was wrong, just like the crocodile was asked by his wife?',
      questions: [
        QuizQuestion(
          id: 'PT002-Q1',
          prompt: 'Where did the monkey tell the crocodile he had left his heart?',
          skill: 'C1_recall',
          options: [
            'Buried in the mud by the river',
            'In the hollow of the rose-apple tree',
            'Inside a secret coconut shell',
            'With the wise old tortoise',
          ],
          correctIndex: 1,
          explanation: 'The monkey quickly invented the story that monkeys store their hearts in tree hollows to trick the crocodile into swimming back.',
        ),
        QuizQuestion(
          id: 'PT002-Q2',
          prompt: 'Why did the monkey remain calm instead of crying out in panic in deep water?',
          skill: 'M3_niti_strategy',
          options: [
            'He wanted to take a bath in the river',
            'He knew that presence of mind was his only escape',
            'He knew the crocodile could not swim well',
            'He had an army of birds waiting',
          ],
          correctIndex: 1,
          explanation: 'Staying calm under pressure allowed the monkey to invent a convincing escape plan.',
        ),
      ],
    ),

    Story(
      storyId: 'PT003',
      title: 'The Blue Jackal',
      tantraBook: 'Book 1: Mitra-bheda (The Loss of Friends)',
      ageBand: '4-9',
      readingMinutes: 7,
      cognitiveLevel: 2,
      coverEmoji: '🐺',
      summary: 'A jackal falls into blue indigo dye and proclaims himself king of all beasts, until his true voice betrays him.',
      adaptedText: '''A hungry jackal named Chandaraka was prowling in a town looking for scraps of food. The town dogs barked fiercely and chased him down a narrow alley.

In his panic, the jackal leapt through a window and landed head-first into a large vat of indigo dye left by a dyer!

When he climbed out, he was colored bright, shining indigo blue from ears to tail. The dogs did not recognize this strange blue beast and ran away terrified.

The jackal looked at himself in a pond and thought: "I look magnificent and mysterious. I can rule the forest with this guise!"

He strode into the jungle. The lions, tigers, and elephants trembled: "What supernatural creature is this?"

Chandaraka puffed out his chest: "Lord Brahma created me with his own hands! He named me Kakudruma and made me the sovereign king of all creatures. Serve me and you will be protected."

For many weeks, the blue jackal lived like a king. The lion brought him venison, the tiger bowed, and the jackal banished his own jackal relatives so they would not recognize him.

One evening at sunset, a pack of jackals in the distance raised their snouts to the moon and began their natural howling: "Owoo! Owoo! Owoo!"

Chandaraka heard his kin. His hair stood on end, his eyes widened with excitement, and forgetting where he was, he tilted his head back and howled loudly: "Owoo! Owoo!"

The tiger and the lion gasped: "He is just a jackal! A painted fraud who fooled us!" In an instant, the beasts chased the pretender away forever.''',
      originalSourceCitation: 'Arthur W. Ryder (1925), Book 1, Fable 10',
      moral: 'Pretense and false identity cannot last; truth always reveals itself.',
      iksConcept: 'Satya (Truthfulness) & Swabhava (Inherent Nature)',
      iksExplanation: 'Indian philosophy teaches that one cannot hide their true nature (Swabhava) under external paint. Truthfulness (Satya) is enduring, while deceit collapses under the lightest test.',
      characters: ['Chandaraka the Jackal', 'Forest Lion & Tiger', 'Town Dogs'],
      themes: ['Honesty', 'Authenticity', 'Ego', 'Consequences'],
      glossary: {
        'Indigo': 'A deep blue natural dye made from plants.',
        'Sovereign': 'A supreme ruler possessing royal power.',
        'Banished': 'Sent away and forbidden to return.',
        'Swabhava': 'The natural inborn character or essence of a being.',
      },
      skillWeights: {
        'C1_recall': 0.75,
        'C2_sequence': 0.85,
        'C3_motive': 0.9,
        'M1_perspective': 0.8,
        'M2_moral_dilemma': 0.95,
        'M3_niti_strategy': 0.7,
      },
      discussionPrompt: 'Why do you think people sometimes pretend to be someone they are not? Is it ever worth hiding who you really are?',
      questions: [
        QuizQuestion(
          id: 'PT003-Q1',
          prompt: 'How did the jackal end up colored bright blue?',
          skill: 'C1_recall',
          options: [
            'He was born with magical blue fur',
            'He fell into a dyer’s tub of indigo dye',
            'He rolled in blue berries',
            'He bathed in a sacred river',
          ],
          correctIndex: 1,
          explanation: 'While fleeing from barking dogs, the jackal accidentally jumped into a tub of blue indigo dye.',
        ),
        QuizQuestion(
          id: 'PT003-Q2',
          prompt: 'What caused the other animals to discover the jackal’s true identity?',
          skill: 'C2_sequence',
          options: [
            'Rain washed away the blue dye',
            'He could not resist howling when he heard other jackals',
            'A hunter came and caught him',
            'He confessed out of guilt',
          ],
          correctIndex: 1,
          explanation: 'His natural instinct to howl alongside his pack betrayed his disguise, proving you cannot suppress your true nature.',
        ),
      ],
    ),
  ];

  static Story getStoryById(String id) {
    return allStories.firstWhere(
      (s) => s.storyId == id,
      orElse: () => allStories.first,
    );
  }
}
