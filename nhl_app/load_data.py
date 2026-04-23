import os
import django

# Setup Django environment so we can use the database models outside of a web request
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from nhl_app.models import Team

# Check if data already exists so we don't duplicate teams every time the container restarts
if not Team.objects.exists():
    print("Database is empty. Populating initial NHL teams...")
    
    Team.objects.create(
        name="Colorado Avalanche", 
        region="Central", 
        logo="team_logos/avalanche.png"
    )
    Team.objects.create(
        name="Boston Bruins", 
        region="Atlantic", 
        logo="team_logos/bruins.png"
    )
    Team.objects.create(
        name="Vegas Golden Knights", 
        region="Pacific", 
        logo="team_logos/knights.png"
    )
    
    print("Successfully populated NHL teams!")
else:
    print("Teams already exist in the database. Skipping data load.")