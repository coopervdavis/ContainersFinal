from django.shortcuts import render
from .models import Team

def team_list(request):
    region_filter = request.GET.get('region')
    if region_filter:
        teams = Team.objects.filter(region=region_filter)
    else:
        teams = Team.objects.all()
        
    regions = Team.objects.values_list('region', flat=True).distinct()
    return render(request, 'nhl_app/team_list.html', {'teams': teams, 'regions': regions})