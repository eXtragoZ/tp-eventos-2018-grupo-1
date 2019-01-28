package edu.algo2.eventos

import org.eclipse.xtend.lib.annotations.Accessors
import edu.algo2.eventos.excepciones.EventoException

@Accessors
class Invitacion {
	EventoCerrado evento
	Usuario invitado
	int acompaniantes = 0
	boolean aceptada = false
	boolean rechazada = false

	new(EventoCerrado _evento, Usuario _invitado, int _acompaniantes) {
		evento = _evento
		invitado = _invitado
		acompaniantes = _acompaniantes
	}

	def void aceptarInvitacion(int acompaniantesConfirmados) {
		validarPuedeAceptarse(acompaniantesConfirmados)
		acompaniantes = acompaniantesConfirmados
		aceptada = true
	}

	def rechazarInvitacion() {
		validarPuedeRechazarse
		rechazada = true
	}

	def cantPosiblesAsistentes() {
		1 + acompaniantes
	}

	def estaPendiente() {
		!aceptada && !rechazada
	}
	
	def validarPuedeAceptarse(int acompaniantesConfirmados) {
		if (!estaPendiente) {
			throw new EventoException("La invitacion ya no esta pendiente")
		}
		if (acompaniantes < acompaniantesConfirmados) {
			throw new EventoException("La cantidad de acompañantes es mayor a la permitida")
		}
		if (0 > acompaniantesConfirmados) {
			throw new EventoException("La cantidad de acompañantes es menor a cero")
		}
		if (!evento.hayTiempoParaConfirmar) {
			throw new EventoException("Ya no hay tiempo para confirmar")
		}
	}
	
	def validarPuedeRechazarse() {
		if (!estaPendiente) {
			throw new EventoException("La invitacion ya no esta pendiente")
		}
	}
	
	def ordenarAceptarInvitacion(int acompaniantesConfirmados) {
		if (invitado.puedeRealizarOrdenesDeInvitacion && estaPendiente) {
			eliminarOrdenesInvitacion()
			evento.agregarOrdenDeInvitacion(new AceptarInvitacion(this, acompaniantesConfirmados))
		} else {
			throw new EventoException("No se puede ordenar el aceptar de la invitacion")
		}
	}
	def ordenarRechazarInvitacion() {
		if (invitado.puedeRealizarOrdenesDeInvitacion && estaPendiente) {
			eliminarOrdenesInvitacion()
			evento.agregarOrdenDeInvitacion(new RechazarInvitacion(this))
		} else {
			throw new EventoException("No se puede ordenar el rechazo de la invitacion")
		}
	}
	def eliminarOrdenesInvitacion() {
		evento.removerOrdenesDeInvitacion(this)
	}
	def enviarNotificacionDeOrden(String tipo, String estado) {
		invitado.recibirNotificacion("Su orden de "+tipo+" la invitacion a sido "+estado+"!")
	}
	
	def esDeEvento(Evento eventoBuscado) {
		evento === eventoBuscado
	}
}
