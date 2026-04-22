from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('nhl_app.urls')), # This forwards all base traffic to your app
]