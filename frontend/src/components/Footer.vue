<template>
  <footer class="footer">
    <div class="footer-content">
      <p>&copy; {{ currentYear }} Kanban App. Все права защищены.</p>
      <div class="footer-links" v-if="showLinks">
        <a href="/about">О нас</a>
        <a href="/privacy">Конфиденциальность</a>
        <a href="/terms">Условия использования</a>
        <a href="/contact">Контакты</a>
      </div>
    </div>
  </footer>
</template>

<script>
export default {
  name: 'AppFooter',
  props: {
    showLinks: {
      type: Boolean,
      default: true
    }
  },
  computed: {
    currentYear() {
      return new Date().getFullYear();
    }
  }
}
</script>

<style scoped>
.footer {
  background: #333;
  color: #fff;
  padding: 1.5rem 2rem;
  margin-top: auto;
}

.footer-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
}

.footer-content p {
  margin: 0;
  font-size: 0.9rem;
}

.footer-links {
  display: flex;
  gap: 1.5rem;
}

.footer-links a {
  color: #fff;
  text-decoration: none;
  font-size: 0.85rem;
  transition: opacity 0.3s ease;
}

.footer-links a:hover {
  opacity: 0.8;
}

@media (max-width: 768px) {
  .footer {
    padding: 1rem;
  }

  .footer-links {
    flex-wrap: wrap;
    justify-content: center;
    gap: 1rem;
  }

  .footer-links a {
    font-size: 0.8rem;
  }
}
</style>