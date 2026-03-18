from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from .views import (
    RegisterView, current_user, dashboard_summary,
    UserProfileViewSet, SavingsPlanViewSet, TransactionViewSet,
    LoanViewSet, LoanPaymentViewSet, PenaltyViewSet,
    InterestDistributionViewSet, NotificationViewSet,
    loan_eligibility, financial_report,
)
from .serializers import CustomTokenObtainPairSerializer

router = DefaultRouter()
router.register(r'profile', UserProfileViewSet)
router.register(r'savings', SavingsPlanViewSet)
router.register(r'transactions', TransactionViewSet)
router.register(r'loans', LoanViewSet)
router.register(r'payments', LoanPaymentViewSet)
router.register(r'penalties', PenaltyViewSet)
router.register(r'interest', InterestDistributionViewSet)
router.register(r'notifications', NotificationViewSet)

urlpatterns = [
    # Auth
    path('auth/register/', RegisterView.as_view(), name='register'),
    path('auth/login/', TokenObtainPairView.as_view(serializer_class=CustomTokenObtainPairSerializer), name='token_obtain_pair'),
    path('auth/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('auth/me/', current_user, name='current_user'),

    # Dashboard (single-call summary)
    path('dashboard/', dashboard_summary, name='dashboard_summary'),

    # Business logic endpoints
    path('loans/eligibility/', loan_eligibility, name='loan_eligibility'),
    path('reports/', financial_report, name='financial_report'),

    # Router URLs
    path('', include(router.urls)),
]
