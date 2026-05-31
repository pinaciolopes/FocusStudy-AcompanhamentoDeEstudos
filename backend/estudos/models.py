from django.db import models
from django.contrib.auth.models import User

# 1. A tabela das Matérias
class Materia(models.Model):
    usuario = models.ForeignKey(User, on_delete=models.CASCADE) 
    nome = models.CharField(max_length=100)
    
    def __str__(self):
        return self.nome

# 2. A tabela das Sessões de Estudo
class SessaoEstudo(models.Model):
    materia = models.ForeignKey(Materia, on_delete=models.CASCADE)
    data = models.DateField()
    horas_estudadas = models.DecimalField(max_digits=4, decimal_places=1)
    anotacoes = models.TextField(blank=True)

    def __str__(self):
        return f"{self.materia.nome} - {self.horas_estudadas}h"
