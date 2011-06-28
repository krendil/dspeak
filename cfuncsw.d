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

module dspeak.cfuncsw;


import dspeak.loaddll;
public import dspeak.types;

import std.stdio;

extern(C){
__gshared:

/** Must be called before any synthesis functions are called.
   output: the audio data can either be played by eSpeak or passed back by the SynthCallback function.

   buflength:  The length in mS of sound buffers passed to the SynthCallback function.

   path: The directory which contains the espeak-data directory, or NULL for the default location.

   options: bit 0:  1=allow espeakEVENT_PHONEME events.
            bit 15: 1=don't exit if espeak_data is not found (used for --help)

   Returns: sample rate in Hz, or -1 (EE_INTERNAL_ERROR).
*/
 int function(espeak_AUDIO_OUTPUT output, int buflength, const char* path, int options) espeak_Initialize;

         /********************/
         /*    Synthesis     */
         /********************/

/** Must be called before any synthesis functions are called.
   This specifies a function in the calling program which is called when a buffer of
   speech sound data has been produced. 


   The callback function is of the form:

int SynthCallback(short *wav, int numsamples, espeak_EVENT *events);

   wav:  is the speech sound data which has been produced.
      NULL indicates that the synthesis has been completed.

   numsamples: is the number of entries in wav.  This number may vary, may be less than
      the value implied by the buflength parameter given in espeak_Initialize, and may
      sometimes be zero (which does NOT indicate end of synthesis).

   events: an array of espeak_EVENT items which indicate word and sentence events, and
      also the occurance if <mark> and <audio> elements within the text.  The list of
      events is terminated by an event of type = 0.


   Callback returns: 0=continue synthesis,  1=abort synthesis.
*/
 void function (t_espeak_callback SynthCallback) espeak_SetSynthCallback;

/** This function may be called before synthesis functions are used, in order to deal with
   <audio> tags.  It specifies a callback function which is called when an <audio> element is
   encountered and allows the calling program to indicate whether the sound file which
   is specified in the <audio> element is available and is to be played.

   The callback function is of the form:

int UriCallback(int type, const char *uri, const char *base);

   type:  type of callback event.  Currently only 1= <audio> element

   uri:   the "src" attribute from the <audio> element

   base:  the "xml:base" attribute (if any) from the <speak> element

   Return: 1=don't play the sound, but speak the text alternative.
           0=place a PLAY event in the event list at the point where the <audio> element
             occurs.  The calling program can then play the sound at that point.
*/
 void function (int function(int, const char*, const char*) UriCallback) espeak_SetUriCallback;

/** Synthesize speech for the specified text.  The speech sound data is passed to the calling
   program in buffers by means of the callback function specified by espeak_SetSynthCallback(). The command is asynchronous: it is internally buffered and returns as soon as possible. If espeak_Initialize was previously called with AUDIO_OUTPUT_PLAYBACK as argument, the sound data are played by eSpeak.

   text: The text to be spoken, terminated by a zero character. It may be either 8-bit characters,
      wide characters (wchar_t), or UTF8 encoding.  Which of these is determined by the "flags"
      parameter.

   size: Equal to (or greatrer than) the size of the text data, in bytes.  This is used in order
      to allocate internal storage space for the text.  This value is not used for
      AUDIO_OUTPUT_SYNCHRONOUS mode.

   position:  The position in the text where speaking starts. Zero indicates speak from the
      start of the text.

   position_type:  Determines whether "position" is a number of characters, words, or sentences.
      Values: 

   end_position:  If set, this gives a character position at which speaking will stop.  A value
      of zero indicates no end position.

   flags:  These may be OR'd together:
      Type of character codes, one of:
         espeakCHARS_UTF8     UTF8 encoding
         espeakCHARS_8BIT     The 8 bit ISO-8859 character set for the particular language.
         espeakCHARS_AUTO     8 bit or UTF8  (this is the default)
         espeakCHARS_WCHAR    Wide characters (wchar_t)

      espeakSSML   Elements within < > are treated as SSML elements, or if not recognised are ignored.

      espeakPHONEMES  Text within [[ ]] is treated as phonemes codes (in espeak's Hirshenbaum encoding).

      espeakENDPAUSE  If set then a sentence pause is added at the end of the text.  If not set then
         this pause is suppressed.

   unique_identifier: message identifier; helpful for identifying later 
     data supplied to the callback.

   user_data: pointer which will be passed to the callback function.

   Return: EE_OK: operation achieved 
           EE_BUFFER_FULL: the command can not be buffered; 
             you may try after a while to call the function again.
	   EE_INTERNAL_ERROR.
*/
 espeak_ERROR function(const void* text,
	size_t size,
	uint position,
	espeak_POSITION_TYPE position_type,
	uint end_position,
	uint flags,
	uint* unique_identifier,
	void* user_data) espeak_Synth;
    
/** Synthesize speech for the specified text.  Similar to espeak_Synth() but the start position is
   specified by the name of a <mark> element in the text.

   index_mark:  The "name" attribute of a <mark> element within the text which specified the
      point at which synthesis starts.  UTF8 string.

   For the other parameters, see espeak_Synth()

   Return: EE_OK: operation achieved 
           EE_BUFFER_FULL: the command can not be buffered; 
             you may try after a while to call the function again.
	   EE_INTERNAL_ERROR.
*/
 espeak_ERROR function(const void* text,
	size_t size,
	const char* index_mark,
	uint end_position,
	uint flags,
	uint* unique_identifier,
	void* user_data) espeak_Synth_Mark;
    
/** Speak the name of a keyboard key.
   If key_name is a single character, it speaks the name of the character.
   Otherwise, it speaks key_name as a text string.

   Return: EE_OK: operation achieved 
           EE_BUFFER_FULL: the command can not be buffered; 
             you may try after a while to call the function again.
	   EE_INTERNAL_ERROR.
*/
 espeak_ERROR function(const char* key_name) espeak_Key;

/** Speak the name of the given character 

   Return: EE_OK: operation achieved 
           EE_BUFFER_FULL: the command can not be buffered; 
             you may try after a while to call the function again.
	   EE_INTERNAL_ERROR.
*/
 espeak_ERROR function(wchar character) espeak_Char;


         /***********************/
         /*  Speech Parameters  */
         /***********************/
         
/** Sets the value of the specified parameter.
   relative=0   Sets the absolute value of the parameter.
   relative=1   Sets a relative value of the parameter.

   parameter:
      espeakRATE:    speaking speed in word per minute.  Values 80 to 450.

      espeakVOLUME:  volume in range 0-200 or more.
                     0=silence, 100=normal full volume, greater values may produce amplitude compression or distortion

      espeakPITCH:   base pitch, range 0-100.  50=normal

      espeakRANGE:   pitch range, range 0-100. 0-monotone, 50=normal

      espeakPUNCTUATION:  which punctuation characters to announce:
         value in espeak_PUNCT_TYPE (none, all, some), 
         see espeak_GetParameter() to specify which characters are announced.

      espeakCAPITALS: announce capital letters by:
         0=none,
         1=sound icon,
         2=spelling,
         3 or higher, by raising pitch.  This values gives the amount in Hz by which the pitch
            of a word raised to indicate it has a capital letter.

      espeakWORDGAP:  pause between words, units of 10mS (at the default speed)

   Return: EE_OK: operation achieved 
           EE_BUFFER_FULL: the command can not be buffered; 
             you may try after a while to call the function again.
	   EE_INTERNAL_ERROR.
*/
 espeak_ERROR function(espeak_PARAMETER parameter, int value, int relative) espeak_SetParameter;

/** current=0  Returns the default value of the specified parameter.
   current=1  Returns the current value of the specified parameter, as set by SetParameter()
*/
 int function(espeak_PARAMETER parameter, int current) espeak_GetParameter;

/** Specified a list of punctuation characters whose names are to be spoken when the
   value of the Punctuation parameter is set to "some".

   punctlist:  A list of character codes, terminated by a zero character.

   Return: EE_OK: operation achieved 
           EE_BUFFER_FULL: the command can not be buffered; 
             you may try after a while to call the function again.
	   EE_INTERNAL_ERROR.
*/
 espeak_ERROR function(const wchar* punctlist)espeak_SetPunctuationList;


/** Controls the output of phoneme symbols for the text
   value=0  No phoneme output (default)
   value=1  Output the translated phoneme symbols for the text
   value=2  as (1), but also output a trace of how the translation was done (matching rules and list entries)
   value=3  as (1), but produces IPA rather than ascii phoneme names

   stream   output stream for the phoneme symbols (and trace).  If stream=NULL then it uses stdout.
*/
 void function(int value, FILE* stream)espeak_SetPhonemeTrace;

/** Compile pronunciation dictionary for a language which corresponds to the currently
   selected voice.  The required voice should be selected before calling this function.

   path:  The directory which contains the language's '_rules' and '_list' files.
          'path' should end with a path separator character ('/').
   log:   Stream for error reports and statistics information. If log=NULL then stderr will be used.

   flags:  Bit 0: include source line information for debug purposes (This is displayed with the
          -X command line option).
*/
 void function(const char* path, FILE* log, int flags)espeak_CompileDictionary;


        /***********************/
        /*   Voice Selection   */
        /***********************/
        
/** Reads the voice files from espeak-data/voices and creates an array of espeak_VOICE pointers.
   The list is terminated by a NULL pointer

   If voice_spec is NULL then all voices are listed.
   If voice spec is given, then only the voices which are compatible with the voice_spec
   are listed, and they are listed in preference order.
*/
 const(espeak_VOICE)** function(espeak_VOICE* voice_spec)espeak_ListVoices;

/** Searches for a voice with a matching "name" field.  Language is not considered.
   "name" is a UTF8 string.

   Return: EE_OK: operation achieved 
           EE_BUFFER_FULL: the command can not be buffered; 
             you may try after a while to call the function again.
	   EE_INTERNAL_ERROR.
*/
 espeak_ERROR function(const char* name)espeak_SetVoiceByName;

/** An espeak_VOICE structure is used to pass criteria to select a voice.  Any of the following
   fields may be set:

   name     NULL, or a voice name

   languages  NULL, or a single language string (with optional dialect), eg. "en-uk", or "en"

   gender   0=not specified, 1=male, 2=female

   age      0=not specified, or an age in years

   variant  After a list of candidates is produced, scored and sorted, "variant" is used to index
            that list and choose a voice.
            variant=0 takes the top voice (i.e. best match). variant=1 takes the next voice, etc
*/
 espeak_ERROR function(espeak_VOICE* voice_spec) espeak_SetVoiceByProperties;


/** Returns the espeak_VOICE data for the currently selected voice.
   This is not affected by temporary voice changes caused by SSML elements such as <voice> and <s>
*/
 espeak_VOICE* function() espeak_GetCurrentVoice;


/** Stop immediately synthesis and audio output of the current text. When this
   function returns, the audio output is fully stopped and the synthesizer is ready to
   synthesize a new message.

   Return: EE_OK: operation achieved 
	   EE_INTERNAL_ERROR.
*/
 espeak_ERROR function() espeak_Cancel;

/** Returns 1 if audio is played, 0 otherwise.
*/
 int function() espeak_IsPlaying;


/** This function returns when all data have been spoken.
   Return: EE_OK: operation achieved 
	   EE_INTERNAL_ERROR.
*/
 espeak_ERROR function() espeak_Synchronize;


/** last function to be called.
   Return: EE_OK: operation achieved 
	   EE_INTERNAL_ERROR.
*/
 espeak_ERROR function() espeak_Terminate;

/** Returns the version number string.
   path_data  returns the path to espeak_data
*/
 const(char*) function(const(char)** path_data) espeak_Info;
 
}
