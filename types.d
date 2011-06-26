 /***********************************************************************
 This file is part of dspeak.

    dspeak is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    dspeak is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with dspeak.  If not, see <http://www.gnu.org/licenses/>.
    
dspeak is simply a D wrapper for espeak

espeak is Copyright (C) 2005 to 2010 by Jonathan Duddington
email: jonsd@users.sourceforge.net 

dspeak is Copyright (C) 2011 to David Osborne
email: krendilboove@gmail.com
*/

module dspeak.types;

/// values for 'value' in espeak_SetParameter(espeakRATE, value, 0), 
/// nominally in words-per-minute
enum {
    espeakRATE_MINIMUM = 80,
    espeakRATE_MAXIMUM = 450,
    espeakRATE_NORMAL = 175
}

enum espeak_EVENT_TYPE{
    espeakEVENT_LIST_TERMINATED = 0, // Retrieval mode: terminates the event list.
    espeakEVENT_WORD = 1,            // Retrieval mode: terminates the event list.
    espeakEVENT_SENTENCE = 2,        // Start of sentence
    espeakEVENT_MARK = 3,            // Mark
    espeakEVENT_PLAY = 4,            // Audio element
    espeakEVENT_END = 5,             // End of sentence or clause
    espeakEVENT_MSG_TERMINATED = 6,  // End of message
    espeakEVENT_PHONEME = 7,         // Phoneme, if enabled in espeak_Initialize()
    espeakEVENT_SAMPLERATE = 8       // internal use, set sample rate
}
alias espeak_EVENT_TYPE EventType;

/** 
   When a message is supplied to espeak_synth, the request is buffered and espeak_synth returns. When the message is really processed, the callback function will be repetedly called.


   In RETRIEVAL mode, the callback function supplies to the calling program the audio data and an event list terminated by 0 (LIST_TERMINATED).

   In PLAYBACK mode, the callback function is called as soon as an event happens.

   For example suppose that the following message is supplied to espeak_Synth: 
   "hello, hello."


   * Once processed in RETRIEVAL mode, it could lead to 3 calls of the callback function :

   ** Block 1:
   <audio data> + 
   List of events: SENTENCE + WORD + LIST_TERMINATED
 
   ** Block 2:
   <audio data> +
   List of events: WORD + END + LIST_TERMINATED

   ** Block 3:
   no audio data
   List of events: MSG_TERMINATED + LIST_TERMINATED


   * Once processed in PLAYBACK mode, it could lead to 5 calls of the callback function:

   ** SENTENCE
   ** WORD (call when the sounds are actually played)
   ** WORD
   ** END (call when the end of sentence is actually played.)
   ** MSG_TERMINATED


   The MSG_TERMINATED event is the last event. It can inform the calling program to clear the user data related to the message.
   So if the synthesis must be stopped, the callback function is called for each pending message with the MSG_TERMINATED event.

   A MARK event indicates a <mark> element in the text.
   A PLAY event indicates an <audio> element in the text, for which the calling program should play the named sound file.
*/
struct espeak_EVENT{
	espeak_EVENT_TYPE type;
	uint unique_identifier; // message identifier (or 0 for key or character)
	int text_position;    // the number of characters from the start of the text
	int length;           // word length, in characters (for espeakEVENT_WORD)
	int audio_position;   // the time in mS within the generated speech output data
	int sample;           // sample id (internal use)
	void* user_data;      // pointer supplied by the calling program
	union id {
		int number;        // used for WORD and SENTENCE events. For PHONEME events this is the phoneme mnemonic.
		const char* name;  // used for MARK and PLAY events.  UTF8 string
	};
}
alias espeak_EVENT Event;

enum espeak_POSITION_TYPE {
    POS_CHARACTER = 1,
	POS_WORD,
	POS_SENTENCE
}
alias espeak_POSITION_TYPE PositionType;

enum espeak_AUDIO_OUTPUT{
    /* PLAYBACK mode: plays the audio data, supplies events to the calling program*/
	AUDIO_OUTPUT_PLAYBACK, 
	/* RETRIEVAL mode: supplies audio data and events to the calling program */
	AUDIO_OUTPUT_RETRIEVAL, 
	/* SYNCHRONOUS mode: as RETRIEVAL but doesn't return until synthesis is completed */
	AUDIO_OUTPUT_SYNCHRONOUS,
	/* Synchronous playback */
	AUDIO_OUTPUT_SYNCH_PLAYBACK
}
alias espeak_AUDIO_OUTPUT AudioOutput;

enum espeak_ERROR{
	EE_OK=0,
	EE_INTERNAL_ERROR=-1,
	EE_BUFFER_FULL=1,
	EE_NOT_FOUND=2
}
alias espeak_ERROR EspeakError;

enum {
    espeakINITIALIZE_PHONEME_EVENTS = 0x0001,
    espeakINITIALIZE_DONT_EXIT = 0x8000
}

alias int function(short*, int, espeak_EVENT*) t_espeak_callback;
alias t_espeak_callback EspeakCallback;

alias int function(int, const char*, const char*) t_espeak_uri_callback;
alias t_espeak_uri_callback EspeakUriCallback;

enum {
    espeakCHARS_AUTO,  
    espeakCHARS_UTF8,
    espeakCHARS_8BIT,
    espeakCHARS_WCHAR,
    espeakCHARS_16BIT
}

enum {
    espeakSSML        = 0x10,
    espeakPHONEMES    = 0x100,
    espeakENDPAUSE    = 0x1000,
    espeakKEEP_NAMEDATA= 0x2000
}

enum espeak_PARAMETER{
  espeakSILENCE=0, /* internal use */
  espeakRATE=1,
  espeakVOLUME=2,
  espeakPITCH=3,
  espeakRANGE=4,
  espeakPUNCTUATION=5,
  espeakCAPITALS=6,
  espeakWORDGAP=7,
  espeakOPTIONS=8,   // reserved for misc. options.  not yet used
  espeakINTONATION=9,

  espeakRESERVED1=10,
  espeakRESERVED2=11,
  espeakEMPHASIS,   /* internal use */
  espeakLINELENGTH, /* internal use */
  espeakVOICETYPE,  // internal, 1=mbrola
  N_SPEECH_PARAM    /* last enum */
}
alias espeak_PARAMETER Parameter;

enum espeak_PUNCT_TYPE{
  espeakPUNCT_NONE=0,
  espeakPUNCT_ALL=1,
  espeakPUNCT_SOME=2
}
alias espeak_PUNCT_TYPE PunctType;

/** Note: The espeak_VOICE structure is used for two purposes:
  1.  To return the details of the available voices.
  2.  As a parameter to  espeak_SetVoiceByProperties() in order to specify selection criteria.

   In (1), the "languages" field consists of a list of (UTF8) language names for which this voice
   may be used, each language name in the list is terminated by a zero byte and is also preceded by
   a single byte which gives a "priority" number.  The list of languages is terminated by an
   additional zero byte.

   A language name consists of a language code, optionally followed by one or more qualifier (dialect)
   names separated by hyphens (eg. "en-uk").  A voice might, for example, have languages "en-uk" and
   "en".  Even without "en" listed, voice would still be selected for the "en" language (because
   "en-uk" is related) but at a lower priority.

   The priority byte indicates how the voice is preferred for the language. A low number indicates a
   more preferred voice, a higher number indicates a less preferred voice.

   In (2), the "languages" field consists simply of a single (UTF8) language name, with no preceding
   priority byte.
*/
struct espeak_VOICE{
	const char* name;      // a given name for this voice. UTF8 string.
	const char* languages;       // list of pairs of (byte) priority + (string) language (and dialect qualifier)
	const char* identifier;      // the filename for this voice within espeak-data/voices
	ubyte gender;  // 0=none 1=male, 2=female,
	ubyte age;     // 0=not specified, or age in years
	ubyte variant; // only used when passed as a parameter to espeak_SetVoiceByProperties
	ubyte xx1;     // for internal use 
	int score;       // for internal use
	void* spare;     // for internal use
}
alias espeak_VOICE Voice;
