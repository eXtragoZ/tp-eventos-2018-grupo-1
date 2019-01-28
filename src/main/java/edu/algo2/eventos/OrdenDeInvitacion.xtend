package edu.algo2.eventos

import org.eclipse.xtend.lib.annotations.Accessors
import edu.algo2.eventos.excepciones.EventoException

@Accessors
abstract class OrdenDeInvitacion {
	Invitacion invitacion
	new(Invitacion _invitacion) {
		invitacion = _invitacion
	}
	def void ejecutarOrden()
}

@Accessors
class AceptarInvitacion extends OrdenDeInvitacion {
	int acompaniantes
	
	new(Invitacion _invitacion, int acompaniantesConfirmados) {
		super(_invitacion)
		acompaniantes = acompaniantesConfirmados
	}
	
	override ejecutarOrden() {
		try {
			invitacion.aceptarInvitacion(acompaniantes)
			invitacion.enviarNotificacionDeOrden("aceptar", "exitosa")
		} catch (EventoException exception) {
			invitacion.enviarNotificacionDeOrden("aceptar", "fallida")
		}
	}
	
}

class RechazarInvitacion extends OrdenDeInvitacion {
	
	new(Invitacion _invitacion) {
		super(_invitacion)
	}
	
	override ejecutarOrden() {
		try {
			invitacion.rechazarInvitacion
			invitacion.enviarNotificacionDeOrden("rechazar", "exitosa")
		} catch (EventoException exception) {
			invitacion.enviarNotificacionDeOrden("rechazar", "fallida")
		}
	}
	
}