from django.db import models

class Team(models.Model):
    REGION_CHOICES = [
        ('Metropolitan', 'Metropolitan'),
        ('Atlantic', 'Atlantic'),
        ('Central', 'Central'),
        ('Pacific', 'Pacific'),
    ]
    
    name = models.CharField(max_length=100)
    region = models.CharField(max_length=50, choices=REGION_CHOICES)
    logo = models.ImageField(upload_to='team_logos/') # Stored in S3

    def __str__(self):
        return self.name