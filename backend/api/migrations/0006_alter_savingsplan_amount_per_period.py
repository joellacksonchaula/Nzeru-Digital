from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0005_savingsplan_title'),
    ]

    operations = [
        migrations.AlterField(
            model_name='savingsplan',
            name='amount_per_period',
            field=models.DecimalField(decimal_places=2, max_digits=12),
        ),
    ]
