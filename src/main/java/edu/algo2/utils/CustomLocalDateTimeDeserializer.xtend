package edu.algo2.utils

import com.fasterxml.jackson.core.JsonParser
import com.fasterxml.jackson.databind.DeserializationContext
import com.fasterxml.jackson.databind.deser.std.StdDeserializer
import java.time.Instant
import java.time.LocalDateTime
import java.time.ZoneOffset

class CustomLocalDateTimeDeserializer extends StdDeserializer<LocalDateTime> {

	new() {
		this(null);
	}

	new(Class<LocalDateTime> t) {
		super(t);
	}

	override deserialize(JsonParser p, DeserializationContext ctxt) {
		val fecha = p.getCodec().readValue(p, String)
		return LocalDateTime.ofInstant(Instant.parse(fecha), ZoneOffset.UTC)
	}

}
