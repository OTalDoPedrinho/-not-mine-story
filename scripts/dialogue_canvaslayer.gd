extends CanvasLayer

@onready var name_label = $Box/Name
@onready var text_label = $Box/Text
@onready var options_container = $"Box/Opções"

func _set_name(nome: String):
	name_label.text = nome

func _set_texto(texto: String):
	text_label.text = texto

func _mostrar_opcoes(opcoes: Array):
	limpar_opcoes()
	for i in range(opcoes.size()):
		var btn = Button.new()
		btn.text = opcoes[i]["texto"]
		btn.pressed.connect(_on_opcao_pressed.bind(i))
		options_container.add_child(btn)

func _hide_opcoes():
	limpar_opcoes()

func limpar_opcoes():
	for child in options_container.get_children():
		child.queue_free()

func _on_opcao_pressed(indice: int):
	Dialogo._choose(indice)

func _input(event):
	# Detecta clique do botão esquerdo do mouse
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if Dialogo.in_dialogue and options_container.get_child_count() == 0:
			Dialogo._avancar()
	# Detecta tecla "act" (espaço, enter, etc.)
	if event.is_action_pressed("act") and Dialogo.in_dialogue:
		if options_container.get_child_count() == 0:
			Dialogo._avancar()
