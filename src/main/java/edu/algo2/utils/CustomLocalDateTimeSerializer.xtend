package edu.algo2.utils

import com.fasterxml.jackson.databind.ser.std.StdSerializer
import java.time.LocalDateTime
import com.fasterxml.jackson.core.JsonGenerator
import com.fasterxml.jackson.databind.SerializerProvider
import java.time.format.DateTimeFormatter

class CustomLocalDateTimeSerializer extends StdSerializer<LocalDateTime> {
 
    static DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy hh:mm");

	new() {
		this(null);
	}
	
    new(Class<LocalDateTime> t) {
        super(t);
    }
 
    override serialize(
      LocalDateTime value, JsonGenerator gen, SerializerProvider arg2) {
        gen.writeString(value.format(formatter));
    }
}