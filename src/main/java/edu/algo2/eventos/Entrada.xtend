package edu.algo2.eventos

import org.eclipse.xtend.lib.annotations.Accessors
import edu.algo2.eventos.excepciones.EventoException

@Accessors
class Entrada {
	
	EventoAbierto evento
	Usuario comprador
	int cantidad

	new(EventoAbierto _evento, Usuario _comprador, int _cantidad) {
		evento = _evento
		comprador = _comprador
		cantidad = _cantidad
	}
	
	def devolver() {
		if (evento.diasRestantes >= 1) {
			comprador.agregarSaldo(evento.valorDevolucion)
			cantidad--
			if (cantidad <= 0) {
				eliminar()
			}
		} else {
			throw new EventoException("No hay tiempo para devolver")
		}
	}
	
	def eliminar() {
		comprador.eliminarEntrada(this)
		evento.eliminarEntrada(this)
	}
	
	def esDeEvento(Evento eventoBuscado) {
		evento === eventoBuscado
	}
}
