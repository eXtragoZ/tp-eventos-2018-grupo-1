package edu.algo2.eventos

import org.uqbar.mailService.MailService
import org.uqbar.mailService.Mail
import edu.algo2.repositorio.RepoUsuarios
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors 
abstract class NotificacionObserver {
	MailService servicioMail
	RepoUsuarios repoUsuarios

	def void enviarNotificacion(Evento evento, Usuario organizador)

	def listadoUsuariosConOrganizadorAmigo(Usuario usuario) {
		repoUsuarios.elementos.filter[amigos.contains(usuario)]
	}

	def enviarMail(Usuario receptor, Usuario emisor, Evento evento, String texto) {
		servicioMail.sendMail(new Mail => [
			to = receptor.nombreApellido
			from = emisor.nombreApellido
			subject = "Han creado un nuevo evento"
			text = texto
		])
	}
}

class NotificarAmigosObserver extends NotificacionObserver {
	override enviarNotificacion(Evento evento, Usuario organizador) {
		organizador.amigos.forEach [
			recibirNotificacion("El usuario " + organizador.nombreUsuario + " ha creado el evento " + evento.nombre)
		]
	}
}

class NotificarUsuariosConOrganizadorAmigoObserver extends NotificacionObserver {
	override enviarNotificacion(Evento evento, Usuario organizador) {
		listadoUsuariosConOrganizadorAmigo(organizador).forEach [
			recibirNotificacion("Tu amigo " + organizador.nombreUsuario + " ha creado el evento " + evento.nombre)
		]
	}
}

class NotificarContactosCercanosObserver extends NotificacionObserver {
	override enviarNotificacion(Evento evento, Usuario organizador) {
		val texto = "El usuario " + organizador.nombreUsuario + " ha creado cerca tuyo el evento " + evento.nombre
		listaContactos(organizador).filter[estaCerca(evento)].forEach [
			recibirNotificacion(texto)
			enviarMail(it, organizador, evento, texto)
		]
	}

	def listaContactos(Usuario organizador) {
		(listadoUsuariosConOrganizadorAmigo(organizador) + organizador.amigos).toSet
	}

}

class NotificarUsuariosCercanosObserver extends NotificacionObserver {
	override enviarNotificacion(Evento evento, Usuario organizador) {
		if (evento.puedeNotificarUsuariosCercanos) {
			repoUsuarios.elementos.filter[estaCerca(evento)].forEach [
				recibirNotificacion("El usuario " + organizador.nombreUsuario + " ha creado cerca tuyo el evento " +
					evento.nombre)
			]
		}
	}
}

class NotificarFansDelArtistaObserver extends NotificacionObserver {
	override enviarNotificacion(Evento evento, Usuario organizador) {
		repoUsuarios.elementos.filter[sigueAlgunArtista(evento)].forEach [
			enviarMail(it, organizador, evento,
				"El usuario " + organizador.nombreUsuario + " ha creado el evento " + evento.nombre +
					" donde participa tu artista favorito.")
		]
	}
}
