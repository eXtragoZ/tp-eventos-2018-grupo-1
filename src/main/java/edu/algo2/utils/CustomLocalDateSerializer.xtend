package edu.algo2.utils

import com.fasterxml.jackson.core.JsonGenerator
import com.fasterxml.jackson.databind.SerializerProvider
import com.fasterxml.jackson.databind.ser.std.StdSerializer
import java.time.LocalDate
import java.time.format.DateTimeFormatter

class CustomLocalDateSerializer extends StdSerializer<LocalDate> {
 
    static DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");

	new() {
		this(null);
	}
	
    new(Class<LocalDate> t) {
        super(t);
    }
 
    override serialize(
      LocalDate value, JsonGenerator gen, SerializerProvider arg2) {
        gen.writeString(value.format(formatter));
    }
}