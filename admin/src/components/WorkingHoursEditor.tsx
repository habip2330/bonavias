import React from 'react';
import { Switch } from './ui/switch';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import type { WorkingHours, DaySchedule } from '../types';

interface WorkingHoursEditorProps {
  workingHours: WorkingHours;
  onChange: (workingHours: WorkingHours) => void;
}

const dayNames = {
  monday: 'Pazartesi',
  tuesday: 'Salı', 
  wednesday: 'Çarşamba',
  thursday: 'Perşembe',
  friday: 'Cuma',
  saturday: 'Cumartesi',
  sunday: 'Pazar'
};

const defaultDaySchedule: DaySchedule = {
  day: '',
  isOpen: true,
  openTime: '09:00',
  closeTime: '22:00'
};

export const WorkingHoursEditor: React.FC<WorkingHoursEditorProps> = ({
  workingHours,
  onChange
}) => {
  const updateDay = (dayKey: keyof WorkingHours, updates: Partial<DaySchedule>) => {
    const updatedWorkingHours = {
      ...workingHours,
      [dayKey]: {
        ...workingHours[dayKey],
        ...updates
      }
    };
    onChange(updatedWorkingHours);
  };

  const copyToAll = (sourceDay: keyof WorkingHours) => {
    const sourceSchedule = workingHours[sourceDay];
    const updatedWorkingHours = Object.keys(dayNames).reduce((acc, day) => {
      acc[day as keyof WorkingHours] = {
        ...sourceSchedule,
        day: dayNames[day as keyof typeof dayNames]
      };
      return acc;
    }, {} as WorkingHours);
    onChange(updatedWorkingHours);
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-lg">Çalışma Saatleri</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        {Object.entries(dayNames).map(([dayKey, dayName]) => {
          const schedule = workingHours[dayKey as keyof WorkingHours] || {
            ...defaultDaySchedule,
            day: dayName
          };

          return (
            <div key={dayKey} className="border rounded-lg p-4 space-y-3">
              <div className="flex items-center justify-between">
                <Label className="text-base font-medium">{dayName}</Label>
                <div className="flex items-center space-x-4">
                  <button
                    type="button"
                    onClick={() => copyToAll(dayKey as keyof WorkingHours)}
                    className="text-xs text-blue-600 hover:text-blue-800 underline"
                  >
                    Tümüne Kopyala
                  </button>
                  <div className="flex items-center space-x-2">
                    <Switch
                      checked={schedule.isOpen}
                      onCheckedChange={(checked) =>
                        updateDay(dayKey as keyof WorkingHours, { isOpen: checked })
                      }
                    />
                    <Label className="text-sm">
                      {schedule.isOpen ? 'Açık' : 'Kapalı'}
                    </Label>
                  </div>
                </div>
              </div>

              {schedule.isOpen && (
                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor={`${dayKey}-open`} className="text-sm">
                      Açılış Saati
                    </Label>
                    <Input
                      id={`${dayKey}-open`}
                      type="time"
                      value={schedule.openTime}
                      onChange={(e) =>
                        updateDay(dayKey as keyof WorkingHours, {
                          openTime: e.target.value
                        })
                      }
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor={`${dayKey}-close`} className="text-sm">
                      Kapanış Saati
                    </Label>
                    <Input
                      id={`${dayKey}-close`}
                      type="time"
                      value={schedule.closeTime}
                      onChange={(e) =>
                        updateDay(dayKey as keyof WorkingHours, {
                          closeTime: e.target.value
                        })
                      }
                    />
                  </div>
                </div>
              )}

              {!schedule.isOpen && (
                <div className="text-sm text-gray-500 italic text-center py-2">
                  Bu gün kapalı
                </div>
              )}
            </div>
          );
        })}
        
        <div className="pt-4 border-t">
          <div className="text-sm text-gray-600">
            <strong>İpucu:</strong> Herhangi bir günün saatlerini diğer günlere kopyalamak için "Tümüne Kopyala" butonunu kullanabilirsiniz.
          </div>
        </div>
      </CardContent>
    </Card>
  );
}; 