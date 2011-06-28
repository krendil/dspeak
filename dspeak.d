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

module dspeak.dspeak;

private import std.conv;
private import std.stdio;
private import std.string;
private import std.traits;

AudioOutput defaultMode;
version(Windows){
    import dspeak.cfuncsw;
    defaultMode = AudioOutput.AUDIO_OUTPUT_SYNCH_PLAYBACK
} else {
    import dspeak.cfuncs;
    defaultMode = AudioOutput.AUDIO_OUTPUT_PLAYBACK
}
public import dspeak.types;


public:

int initialize(AudioOutput output, int bufLength, string path, int options){
    return espeak_Initialize(output, bufLength, toStringz(path), options);
}
///Simple version with playback mode, default path, 500ms buffer and no special options
int initialize(){
    return espeak_Initialize(defaultMode, 500, null, 0);
}

void setSynthCallback(EspeakCallback synthCallBack){
    espeak_SetSynthCallback(synthCallBack);
}

void setUriCallback(int function(int, const char*, const char*) uriCallback){
    espeak_SetUriCallback(uriCallback);
}

EspeakError synth(string text, uint position, PositionType ptype, uint endPosition,
                  uint flags, uint* uniqueID, void* userData){
    //Converts text, and automatically fills in size
    return espeak_Synth(cast(const void*)text, text.length, position, ptype, endPosition,
                  flags, uniqueID, userData);
}

EspeakError synth(wstring text, uint position, PositionType ptype, uint endPosition,
                  uint flags, uint* uniqueID, void* userData){
    //Converts text, and automatically fills in size, and ensures wchar flag is set
    return espeak_Synth(cast(const void*)text, text.length*2, position, ptype, endPosition,
                  flags|espeakCHARS_WCHAR, uniqueID, userData);
}

///Simple version, reads all utf8 text with ssml and phonemes enables, and no callback data
EspeakError synth(string text){
    uint flags = espeakCHARS_UTF8 | espeakSSML | espeakPHONEMES;
    return espeak_Synth(cast(const void*)toStringz(text), text.length, 0, PositionType.POS_CHARACTER,
                    0, flags, null, null);
}

///Simple version, reads all utf16 text with ssml and phonemes enables, and no callback data
EspeakError synth(wstring text){
    uint flags = espeakCHARS_WCHAR | espeakSSML | espeakPHONEMES;
    return espeak_Synth(cast(const void*)text, text.length*2, 0, PositionType.POS_CHARACTER,
                    0, flags, null, null);
}

EspeakError synthMark(string text, string mark, uint endPosition, uint flags,
                      uint* uniqueID, void* userData){
    //Converts text, and automatically fills in size
    return espeak_Synth_Mark(cast(const void*)text, text.length, toStringz(mark),
                              endPosition, flags, uniqueID, userData);
}

EspeakError synthMark(wstring text, string mark, uint endPosition, uint flags,
                      uint* uniqueID, void* userData){
    //Converts text, and automatically fills in size
    return espeak_Synth_Mark(cast(const void*)text, text.length*2, toStringz(mark),
                              endPosition, flags, uniqueID, userData);
}

EspeakError key(string keyName){
    return espeak_Key(toStringz(keyName));
}

EspeakError character(wchar character){
    return espeak_Char(character);
}

EspeakError setParameter(Parameter parameter, int value, bool relative){
    return espeak_SetParameter(parameter, value, relative);
}

int getParameter(Parameter parameter, bool current = true){
    return espeak_GetParameter(parameter, current);
}

EspeakError setPunctuationList(wstring punctList){
    return espeak_SetPunctuationList(cast(immutable(wchar)*)(punctList~"/0"w));
}

void setPhonemeTrace(int value, File stream){
    espeak_SetPhonemeTrace(value, stream.getFP());
}

void setPhonemeTrace(int value){
    //espeak redirects output to stdout if stream is null
    espeak_SetPhonemeTrace(value, null);
}

void compileDictionary(string path, File log, int flags){
    espeak_CompileDictionary(toStringz(path), log.getFP(), flags);
}

void compileDictionary(string path, int flags){
    //espeak redirects output to stderr if stream is null
    espeak_CompileDictionary(toStringz(path), null, flags);
}

const(Voice)*[] listVoices(Voice* voiceSpec){
    return toArray(espeak_ListVoices(voiceSpec));
}

EspeakError setVoice(string name){
    return espeak_SetVoiceByName(toStringz(name));
}

EspeakError setVoice(Voice* voiceSpec){
    return espeak_SetVoiceByProperties(voiceSpec);
}

Voice* getCurrentVoice(){
    return espeak_GetCurrentVoice();
}

EspeakError cancel(){
    return espeak_Cancel();
}

bool isPlaying(){
    return (espeak_IsPlaying() == 1);
}

EspeakError synchronize(){
    return espeak_Synchronize();
}

EspeakError terminate(){
    return espeak_Terminate();
}

string info(out const(char)** pathData){
    return to!string(espeak_Info(pathData));
}

private:

//Converts a null-terminated list of pointers to a dynamic array
T*[] toArray(T)(T** data){
    size_t i;
    for(i = 0; data[i] !is null; ++i){}
    return data[0..i];
}
