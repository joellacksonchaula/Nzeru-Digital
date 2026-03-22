from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0004_savingsplan_created_at_savingsplan_is_secret'),
    ]

    operations = [
        migrations.AddField(
            model_name='savingsplan',
            name='title',
            field=models.CharField(default='Savings Plan', max_length=120),
        ),
    ]
