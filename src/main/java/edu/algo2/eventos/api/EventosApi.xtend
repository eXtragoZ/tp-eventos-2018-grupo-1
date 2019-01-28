package edu.algo2.eventos.api

import org.uqbar.xtrest.api.XTRest
import edu.algo2.eventos.controller.EventosController
import edu.algo2.eventos.config.ServiceBootstrap

class EventosApi {
	def static void main(String[] args) {
		ServiceBootstrap.run
		XTRest.start(9000, EventosController)
	}
}