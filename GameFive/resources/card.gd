extends Resource

class_name Card

# Enums for card suits
enum SUIT {HEARTS,DIAMONDS, CLUBS,SPADES}

# Constants for face cards
const JACK = 11
const QUEEN = 12
const KING = 13
const ACE = 14

# Card properties with export hints for inspector visibility
@export var suit: SUIT
@export var value: int  # 2-14 (2-10, J, Q, K, A)

# Constructor
func _init(p_suit: SUIT = SUIT.HEARTS, p_value: int = 2):
	suit = p_suit
	value = p_value
	# Validate the card value
	assert(value >= 2 and value <= 14, "Card value must be between 2 and 14")

# Returns string representation of card value
func get_display_value() -> String:
	match value:
		JACK: return "J"
		QUEEN: return "Q"
		KING: return "K"
		ACE: return "A"
		_: return str(value)

# Returns the Blackjack value of the card
func get_blackjack_value() -> int:
	if value >= JACK and value <= KING:
		return 10  # Face cards are worth 10
	elif value == ACE:
		return 11  # Initial value of Ace (game logic will handle 1 or 11)
	else:
		return value  # Number cards are worth their face value

# Check if card is an Ace
func is_ace() -> bool:
	return value == ACE

# Returns string representation of the suit
func get_suit_string() -> String:
	match suit:
		SUIT.HEARTS: return "Hearts"
		SUIT.DIAMONDS: return "Diamonds"
		SUIT.CLUBS: return "Clubs"
		SUIT.SPADES: return "Spades"
		_: return ""

# Returns the full name of the card (e.g., "King of Hearts")
func get_full_name() -> String:
	var value_str = ""
	match value:
		JACK: value_str = "Jack"
		QUEEN: value_str = "Queen"
		KING: value_str = "King"
		ACE: value_str = "Ace"
		_: value_str = str(value)
	
	return value_str + " of " + get_suit_string()

# Returns a short representation of the card (e.g., "K♥")
func get_short_name() -> String:
	var suit_symbol = ""
	match suit:
		SUIT.HEARTS: suit_symbol = "♥"
		SUIT.DIAMONDS: suit_symbol = "♦"
		SUIT.CLUBS: suit_symbol = "♣"
		SUIT.SPADES: suit_symbol = "♠"
	
	return get_display_value() + suit_symbol
