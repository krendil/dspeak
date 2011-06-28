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
module dspeak.loaddll;

import derelict.util.loader;

import dspeak.cfuncs;
debug import std.stdio;

EspeakLoader loader;

static this(){
    debug writeln("Loading library");
    loader = new EspeakLoader();
    loader.load();
}
static ~this(){
    loader.unload();
}

class EspeakLoader : SharedLibLoader {
    public this(){
        super("espeak_lib.dll", "", "");
    }
    protected override void loadSymbols(){
        bindFunc(cast(void**)&espeak_Initialize, "espeak_Initialize");
        bindFunc(cast(void**)&espeak_SetSynthCallback, "espeak_SetSynthCallback");
        bindFunc(cast(void**)&espeak_SetUriCallback, "espeak_SetUriCallback");
        bindFunc(cast(void**)&espeak_Synth, "espeak_Synth");
        bindFunc(cast(void**)&espeak_Synth_Mark, "espeak_Synth_Mark");
        bindFunc(cast(void**)&espeak_Key, "espeak_Key");
        bindFunc(cast(void**)&espeak_Char, "espeak_Char");
        bindFunc(cast(void**)&espeak_SetParameter, "espeak_SetParameter");
        bindFunc(cast(void**)&espeak_GetParameter, "espeak_GetParameter");
        bindFunc(cast(void**)&espeak_SetPunctuationList, "espeak_SetPunctuationList");
        bindFunc(cast(void**)&espeak_SetPhonemeTrace, "espeak_SetPhonemeTrace");
        bindFunc(cast(void**)&espeak_CompileDictionary, "espeak_CompileDictionary");
        bindFunc(cast(void**)&espeak_ListVoices, "espeak_ListVoices");
        bindFunc(cast(void**)&espeak_SetVoiceByName, "espeak_SetVoiceByName");
        bindFunc(cast(void**)&espeak_SetVoiceByProperties, "espeak_SetVoiceByProperties");
        bindFunc(cast(void**)&espeak_GetCurrentVoice, "espeak_GetCurrentVoice");
        bindFunc(cast(void**)&espeak_Cancel, "espeak_Cancel");
        bindFunc(cast(void**)&espeak_IsPlaying, "espeak_IsPlaying");
        bindFunc(cast(void**)&espeak_Synchronize, "espeak_Synchronize");
        bindFunc(cast(void**)&espeak_Terminate, "espeak_Terminate");
        bindFunc(cast(void**)&espeak_Info, "espeak_Info");
    }
}
