package edu.algo2.eventos

import com.fasterxml.jackson.annotation.JsonValue

abstract class TipoDeUsuario {
	def boolean puedeOrganizarEvento(Usuario usuario, Evento evento)

	def boolean puedeModificarEstadoEvento()

	def boolean invitacionValida(Invitacion invitacion)

	def boolean puedeOrganizarEventosAbiertos()

	def boolean puedeRealizarOrdenesDeInvitacion()

	@JsonValue
	def String getDescripcion()
	
	override toString() {
		"Usuario " + descripcion
	}
}

class TipoUsuarioFree extends TipoDeUsuario {

	override puedeOrganizarEvento(Usuario usuario, Evento evento) {
		usuario.eventosActivos == 0 && usuario.eventosEnMes(evento) < 3
	}

	override puedeModificarEstadoEvento() {
		false
	}

	override invitacionValida(Invitacion invitacion) {
		invitacion.evento.invitadosActivos + invitacion.cantPosiblesAsistentes <= 50
	}

	override puedeOrganizarEventosAbiertos() {
		false
	}

	override puedeRealizarOrdenesDeInvitacion() {
		false
	}
	
	override getDescripcion() {
		"Free"
	}
	
}

class TipoUsuarioAmateur extends TipoDeUsuario {

	override puedeOrganizarEvento(Usuario usuario, Evento evento) {
		usuario.eventosActivos < 5
	}

	override puedeModificarEstadoEvento() {
		true
	}

	override invitacionValida(Invitacion invitacion) {
		invitacion.evento.cantidadInvitaciones < 50
	}

	override puedeOrganizarEventosAbiertos() {
		true
	}

	override puedeRealizarOrdenesDeInvitacion() {
		false
	}
	
	override getDescripcion() {
		"Amateur"
	}
}

class TipoUsuarioProfesional extends TipoDeUsuario {

	override puedeOrganizarEvento(Usuario usuario, Evento evento) {
		usuario.eventosEnMes(evento) < 20
	}

	override puedeModificarEstadoEvento() {
		true
	}

	override invitacionValida(Invitacion invitacion) {
		true
	}

	override puedeOrganizarEventosAbiertos() {
		true
	}

	override puedeRealizarOrdenesDeInvitacion() {
		true
	}
	
	override getDescripcion() {
		"Profesional"
	}
}
