#ifndef QMLPREVIEWER_H
#define QMLPREVIEWER_H

#include <QFileSystemWatcher>
#include <QObject>
#include <QQuickItem>
#include <QQuickView>

class QmlPreviewer : public QObject
{
    Q_OBJECT
public:
    explicit QmlPreviewer(QApplication &app);

signals:

public slots:
    void reload(QString path);
    void show();
private:
    QFileSystemWatcher m_watcher;
    QQuickView m_view;
    QQuickItem *m_rootItem = nullptr;
    QString m_projectPath;
    QString m_filePath;
    QObject *m_object = nullptr;
};

#endif // QMLPREVIEWER_H
