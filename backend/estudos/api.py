from ninja import NinjaAPI, ModelSchema
from ninja_jwt.authentication import JWTAuth
from ninja_jwt.routers.obtain import obtain_pair_router
from django.contrib.auth.models import User
from django.contrib.auth.hashers import make_password
from django.shortcuts import get_object_or_404
from typing import List
from .models import Materia, SessaoEstudo

api = NinjaAPI(title="FocusStudy API", version="1.0.0")

# ==========================================
# 1. ROTAS DE USUÁRIO E AUTENTICAÇÃO
# ==========================================

api.add_router("/auth", obtain_pair_router)

class UserCreateSchema(ModelSchema):
    class Meta:
        model = User
        fields = ['username', 'email', 'password']

@api.post("/usuarios/registrar")
def registrar_usuario(request, payload: UserCreateSchema):
    if User.objects.filter(username=payload.username).exists():
        return api.create_response(request, {"mensagem": "Este nome de usuário já está em uso."}, status=400)

    User.objects.create(
        username=payload.username,
        email=payload.email,
        password=make_password(payload.password)
    )
    return {"sucesso": True, "mensagem": "Usuário criado com sucesso!"}

# --- NOVA ROTA: DELETAR O PRÓPRIO USUÁRIO ---
@api.delete("/usuarios/me", auth=JWTAuth())
def deletar_proprio_usuario(request):
    """
    Remove o usuário que está logado e todos os seus dados vinculados.
    """
    usuario = request.user
    usuario.delete() # O Django remove automaticamente matérias e sessões (se houver CASCADE)
    return {"sucesso": True, "mensagem": "Sua conta foi excluída permanentemente."}


# ==========================================
# 2. SCHEMAS
# ==========================================

class MateriaSchema(ModelSchema):
    class Meta:
        model = Materia
        fields = ['id', 'nome']

class MateriaCreateSchema(ModelSchema):
    class Meta:
        model = Materia
        fields = ['nome']

class SessaoEstudoSchema(ModelSchema):
    materia_id: int
    class Meta:
        model = SessaoEstudo
        fields = ['id', 'data', 'horas_estudadas', 'anotacoes']

class SessaoEstudoCreateSchema(ModelSchema):
    materia_id: int
    class Meta:
        model = SessaoEstudo
        fields = ['data', 'horas_estudadas', 'anotacoes']


# ==========================================
# 3. ROTAS DE MATÉRIAS (Protegidas)
# ==========================================

@api.get("/materias", response=List[MateriaSchema], auth=JWTAuth())
def listar_materias(request):
    return Materia.objects.filter(usuario=request.user)

@api.post("/materias", response=MateriaSchema, auth=JWTAuth())
def criar_materia(request, payload: MateriaCreateSchema):
    return Materia.objects.create(usuario=request.user, **payload.dict())

@api.put("/materias/{materia_id}", response=MateriaSchema, auth=JWTAuth())
def atualizar_materia(request, materia_id: int, payload: MateriaCreateSchema):
    materia = get_object_or_404(Materia, id=materia_id, usuario=request.user)
    materia.nome = payload.nome
    materia.save()
    return materia

@api.delete("/materias/{materia_id}", auth=JWTAuth())
def deletar_materia(request, materia_id: int):
    materia = get_object_or_404(Materia, id=materia_id, usuario=request.user)
    materia.delete()
    return {"sucesso": True, "mensagem": "Matéria apagada!"}


# ==========================================
# 4. ROTAS DE SESSÕES (Protegidas)
# ==========================================

@api.get("/sessoes", response=List[SessaoEstudoSchema], auth=JWTAuth())
def listar_sessoes(request):
    return SessaoEstudo.objects.filter(materia__usuario=request.user).order_by('-data')

@api.post("/sessoes", response=SessaoEstudoSchema, auth=JWTAuth())
def criar_sessao(request, payload: SessaoEstudoCreateSchema):
    dados = payload.dict()
    materia_id = dados.pop('materia_id')
    materia = get_object_or_404(Materia, id=materia_id, usuario=request.user)
    return SessaoEstudo.objects.create(materia=materia, **dados)

@api.put("/sessoes/{sessao_id}", response=SessaoEstudoSchema, auth=JWTAuth())
def atualizar_sessao(request, sessao_id: int, payload: SessaoEstudoCreateSchema):
    sessao = get_object_or_404(SessaoEstudo, id=sessao_id, materia__usuario=request.user)
    
    dados = payload.dict()
    materia_id = dados.pop('materia_id')
    materia = get_object_or_404(Materia, id=materia_id, usuario=request.user)
    
    sessao.materia = materia
    for attr, value in dados.items():
        setattr(sessao, attr, value)
    
    sessao.save()
    return sessao

@api.delete("/sessoes/{sessao_id}", auth=JWTAuth())
def deletar_sessao(request, sessao_id: int):
    sessao = get_object_or_404(SessaoEstudo, id=sessao_id, materia__usuario=request.user)
    sessao.delete()
    return {"sucesso": True, "mensagem": "Sessão apagada!"}