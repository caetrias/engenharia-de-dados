variable "sufixo" {
  type        = string
  description = "Sufixo unico (so minusculas e numeros; sem hifen, por causa do Glue)."
}

variable "teto_bytes" {
  type = number
}
