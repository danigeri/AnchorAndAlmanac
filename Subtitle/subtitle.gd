extends MarginContainer

@onready var tutorial: Node2D = $Tutorial

var text := ""
var duration := 0
var char_index := 0
var subtitles: Array[SubtitleItem] = [
	SubtitleItem.new(
		38,
		(
			"June 24. We set sail on our ship the Lady Bastet from Puerto Gerappo "
			+ "to be the first to sail past the icy Cape Loïc. We took all the supplies "
			+ "we could get here, tea, nuts, hard tack - whatever we could find, for "
			+ "there is no telling when we will be able to restock. We head South West "
			+ "through the bay. The mists make it impossible to see our surroundings, "
			+ "but the wind favours us."
		)
	),
	SubtitleItem.new(
		30,
		(
			"July 9. We passed a welcome sight: the lighthouse of Great Bear Bay. "
			+ "It feels as if its fire warms our weary bones in the chill of the night. "
			+ "This will be the last sign of civilization on our journey for a long time. "
			+ "The crew is filled with anticipation. Tomorrow, we head West."
		)
	),
	SubtitleItem.new(
		30,
		(
			"August 2. Our first death. Sir Kenneth Kendo, our quartermaster, fell "
			+ "sick last night, and did not make it through the night. The doctor said "
			+ "it was the chilling cold that took him. We stopped and had the men build "
			+ "a funeral pyre. I have a terrible feeling that this won't be the last "
			+ "funeral of our journey."
		)
	),
	SubtitleItem.new(
		29,
		(
			"August 29. We see a giant, lonely cedar tree on top of the crags. An "
			+ "unlikely resident in this harsh environment. The crew says it's a bad omen. "
			+ "I don't share their superstitions, but it does seem like we are sailing "
			+ "in circles. I cannot admit it to them, but we are lost."
		)
	),
	SubtitleItem.new(
		36,
		(
			"September 21. A gruesome day. We were ambushed by the Grand Leviathan, "
			+ "the Elephant of the Sea, as they call her. We fought off the beast, earning "
			+ "a bloody victory. We're yet to count our losses, but I estimate that at least "
			+ "a dozen men have fallen. More unfortunate that the ship was also hit hard. "
			+ "We will see to our damages tomorrow at daylight."
		)
	),
	SubtitleItem.new(
		45,
		(
			"October 5. It's been two weeks since our ship was attacked. The rudder was "
			+ "seriously damaged, our uncontrollable ship stranded on a small island. We "
			+ "set camp there. It took days to fix the damages, and remove all unnecessary "
			+ "weight, but now we can finally move. We must head North fast, but I'm afraid "
			+ "it's already too late. The Arctic Ice Barrier blocks our path. We must wait "
			+ "'til summer until the ice melts. It's freezing cold and the morale is at an "
			+ "all time low."
		)
	),
	SubtitleItem.new(
		39,
		(
			"November 18. I leave with the last lifeboat, as the sole survivor of the crew. "
			+ "Our ship was trapped in ice. We couldn't break free. Some of us froze, some died "
			+ "of sickness or disease, or of thirst. Last night, the Lady Bastet finally gave up. "
			+ "The boards shattered, people fell into the icy waters never to emerge again. "
			+ "Our once proud galleon is no more."
		)
	),
	(
	SubtitleItem
	. new(
		41,
		(
			"We found my father's frozen remains on a nameless island. I recognised him not from "
			+ "his clothes, but from his old cutlass, that he held tightly to his chest 'til the very end. "
			+ "I recon, he found passage through the ice with his boat, eventually reaching Cape Loïc. "
			+ "I buried him along his journal. "
			+ "He couldn't make it home, but it was him who first discovered "
			+ "this desolate passage, not us. I named the island Isola Frederico after my father. May he, "
			+ "whose fate was sealed by his curiosity, rest in peace now."
		)
	)
	),
	(
	SubtitleItem
	. new(
		25,
		(
			"Oi, laddie! Were at the bay fishing on me boat when I found this. "
			+ "Washed up on the rocks, Neptune knows how it got home.. "
			+ "'Tis the first page of your father's journal, I'm bloody sure.. "
			+ "His ship's log, I tells ya! You 'swell follow his voyage through the Arctic, eh? "
			+ "Hm. It belongs to you now, laddie. May ye can find him widdit, or may ye find what he could not."
		)
	)
	)
]

@onready var timer: Timer = $Timer
@onready var label: Label = $MarginContainer/Label
@onready var duration_timer: Timer = $DurationTimer


func type_text(checkpoint_number: int) -> void:
	tutorial.hide()
	var subtitle = subtitles[checkpoint_number]
	text = subtitle.subtitle
	duration = subtitle.duration
	char_index = 0
	label.text = ""
	timer.start()
	duration_timer.start(duration)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_timer_timeout() -> void:
	if char_index >= text.length():
		return
	label.text += text[char_index]
	char_index += 1
	timer.start()


func _on_duration_timer_timeout() -> void:
	label.text = ""
	tutorial.show()
