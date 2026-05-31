from django.contrib import admin
from .models import Materia, SessaoEstudo

# Isso aqui customiza a lista no painel
class SessaoEstudoAdmin(admin.ModelAdmin):
    list_display = ('materia', 'data', 'horas_estudadas') # As colunas que vão aparecer

admin.site.register(Materia)
admin.site.register(SessaoEstudo, SessaoEstudoAdmin)