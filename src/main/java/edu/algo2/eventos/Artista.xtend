package edu.algo2.eventos

import org.eclipse.xtend.lib.annotations.Accessors
import com.fasterxml.jackson.annotation.JsonValue

@Accessors
class Artista {
	@JsonValue
	String nombre
	
	new(String _nombre){
		nombre = _nombre
	}
}